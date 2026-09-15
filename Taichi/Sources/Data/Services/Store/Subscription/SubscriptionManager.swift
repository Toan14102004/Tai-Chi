//
//  SubscriptionManager.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/6/25.
//

import Foundation
import StoreKit
import SwiftUI

class SubscriptionManager: ObservableObject {
    @Injected var adsManager: AdsManager
    
    @Navigation var navigator

    @Published var subscriptionStatus: SubscriptionManager.SubscriptionStatus = .notSubscribed {
        didSet {
            switch subscriptionStatus {
            case .subscribed:
                hasActiveSubscription = true
            default:
                break
            }
        }
    }

    @Published var currentSubscription: SubscriptionInfo?
    @Published var isLoading = false
    @Published var statusMessage = ""
    @Published var availableProducts: [Product] = []
    @Published var introductoryOfferEligibility: [String: Bool] = [:]
    /// Whether StoreKit reports a live entitlement. Read `isSubscribed` instead — while IAP is
    /// switched off this stays `false` but the app still behaves as if everything were paid for.
    @Published var hasActiveSubscription: Bool = false

    /// With `AppFlags.iapEnabled` off, version 1 hands every user what a subscriber gets: no ads,
    /// no upsell, no locked workouts. Every caller already asks this question in that direction
    /// ("hide the paywall", "unlock this"), so reporting `true` is all it takes to make the app
    /// free — no call site checks the flag itself.
    var isSubscribed: Bool { AppFlags.iapEnabled ? hasActiveSubscription : true }

    /// Whether ads should be withheld from this user. While IAP is unshipped `isSubscribed` reports
    /// `true` to unlock the app and hide the paywall -- but that is a free user, not a paying one,
    /// so ads still apply. Only a real purchase hides them.
    var hidesAds: Bool { AppFlags.iapEnabled ? hasActiveSubscription : false }

    private var productIds: [String] {
        let localStorage = LocalStorageService.shared
        
        let weeklyProduct: AutoRenewableSubscription = localStorage.weeklyFreeTrialEnabled ? .weeklyFreeTrial : .weekly
        
        let monthlyProduct: AutoRenewableSubscription = localStorage.monthlyFreeTrialEnabled ? .monthlyFreeTrial : .monthly
        
        let yearlyProduct: AutoRenewableSubscription = localStorage.yearlyFreeTrialEnabled ? .yearlyFreeTrial : .yearly
        
        return [
            weeklyProduct.productId,
            monthlyProduct.productId,
            yearlyProduct.productId,
        ]
    }

    init() {
        // Nothing to sell while IAP is switched off: skip the StoreKit round trips entirely
        // rather than fetching products no screen can reach.
        guard AppFlags.iapEnabled else { return }

        // Load products and validate current entitlement on startup
        Task { await fetchSubscriptionProducts() }
        Task { await validateCurrentSubscription() }

        // Listen to transaction updates to keep state in sync
        Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self else { continue }
                switch result {
                case let .unverified(_, error):
                    print("🔴 Unverified transaction: \(String(describing: error))")
                case let .verified(transaction):
                    await handleVerifiedTransaction(transaction)
                }
            }
        }

        // lắng nghe Remote Config update
        NotificationCenter.default.addObserver(forName: .appConfigReady, object: nil, queue: .main) { [weak self] _ in
            Task {
                await self?.fetchSubscriptionProducts()
                await self?.validateCurrentSubscription()
            }
        }
    }

//    func handle(action: @escaping SimpleClosure) {
//        if isSubscribed {
//            action()
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                self.navigator.presentCover(RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .home), withNavigation: true)
//            })
//        }
//    }

    // MARK: - Fetch Products

    @MainActor
    func fetchSubscriptionProducts() async {
        isLoading = true
        do {
            let allProductIds = Set(productIds)
            print("🛒 [IAP] Requesting product IDs: \(allProductIds)")
            let products = try await Product.products(for: allProductIds)
            print("🛒 [IAP] Fetched \(products.count) products from StoreKit")
            for p in products {
                print("🛒 [IAP]   - \(p.id): \(p.displayName) = \(p.displayPrice)")
            }
            
            let subscriptionProducts = products.filter { productIds.contains($0.id) }
            let subscriptionProductSorted = subscriptionProducts.sorted { p1, p2 in
                let i1 = self.productIds.firstIndex(of: p1.id) ?? Int.max
                let i2 = self.productIds.firstIndex(of: p2.id) ?? Int.max
                return i1 < i2
            }
            self.availableProducts = subscriptionProductSorted
            print("🛒 [IAP] Available products count: \(self.availableProducts.count)")
            
            await refreshIntroductoryOfferEligibility()
        } catch {
            print("🛒 [IAP] ❌ Failed to fetch products: \(error)")
        }
        isLoading = false
    }

    // MARK: - Purchase Subscription

    func purchaseSubscription(productId: String, onSuccess: @escaping StringClosure, onError: @escaping StringClosure) {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }

            var product: Product?
            
            if let productSubscription = availableProducts.first(where: { $0.id == productId }) {
                product = productSubscription
            }
            
            guard let product else {
                onError("Product not found".localizedString)
                return
            }

            do {
                adsManager.suppressSplashInterstitialOnce()
                let result = try await product.purchase()
                switch result {
                case let .success(verification):
                    switch verification {
                    case let .verified(transaction):
                        await transaction.finish()
                        
                        let amount: Double = {
                            if let value = try? NSDecimalNumber(decimal: product.price).doubleValue {
                                return value
                            }
                        }()
                        let currency: String = product.priceFormatStyle.currencyCode
                        let receiptData: Data? = fetchReceiptData()
                        
                        onSuccess("Purchase successful!".localizedString)
                        statusMessage = "Purchase successful!".localizedString
                        await validateCurrentSubscription()
                    case let .unverified(_, error):
                        onError("\("Purchase verification failed".localizedString): \(error.localizedDescription)")
                        statusMessage = "Purchase verification failed".localizedString
                    }
                case .userCancelled:
                    onError("Payment cancelled".localizedString)
                    statusMessage = "Payment cancelled".localizedString
                case .pending:
                    statusMessage = "Purchase pending approval".localizedString
                @unknown default:
                    onError("Unknown purchase result".localizedString)
                }
            } catch {
                onError(error.localizedDescription)
                statusMessage = "Purchase failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases(onSuccess: @escaping StringClosure, onError: @escaping StringClosure) {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                try await AppStore.sync()
                await validateCurrentSubscription()
                onSuccess("Purchases restored successfully!".localizedString)
                statusMessage = "Purchases restored successfully".localizedString
            } catch {
                onError("Restore failed".localizedString)
                statusMessage = "Restore failed".localizedString
            }
        }
    }

    // MARK: - Validate Current Subscription

    @MainActor
    func validateCurrentSubscription() async {
        isLoading = true
        defer { isLoading = false }

        var foundActive: SubscriptionManager.SubscriptionInfo?
        var latestExpiry: Date?

        // Check current entitlements for active transactions
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            switch entitlement {
            case let .verified(transaction):
                let pid = transaction.productID
                // Lifetime non-consumable
                if pid == NonConsumableProduct.lifetime.productId {
                    subscriptionStatus = SubscriptionManager.SubscriptionStatus.lifetime
                    currentSubscription = nil
                    statusMessage = "Lifetime access".localizedString
                    return
                }

                guard productIds.contains(pid) else { continue }

                if let expiry = transaction.expirationDate {
                    if latestExpiry == nil || expiry > latestExpiry! {
                        latestExpiry = expiry
                        print("✅ Active subscription found for \(pid)")
                        print("Expiry date: \(String(describing: latestExpiry))")
                        let subEnum = AutoRenewableSubscription(productId: pid)
                        let subInfo = SubscriptionManager.SubscriptionInfo(
                            productId: pid,
                            displayName: subEnum?.displayName ?? "",
                            purchaseDate: transaction.purchaseDate,
                            expiryDate: expiry,
                            isActive: expiry > Date(),
                            isInTrialPeriod: transaction.offerType == .introductory,
                            isInIntroOfferPeriod: transaction.offerType == .introductory,
                            subscriptionPeriod: subEnum?.periodString ?? "Unknown",
                            introductoryOfferInfo: getIntroductoryOfferInfo(for: pid)
                        )
                        foundActive = subInfo
                    }
                }
            case let .unverified(_, error):
                print("Unverified entitlement: \(error)")
            }
        }

        if let active = foundActive, active.isActive {
            currentSubscription = active
            subscriptionStatus = SubscriptionManager.SubscriptionStatus.subscribed(expiryDate: active.expiryDate)
            statusMessage = "\("Active subscription".localizedString): \(active.displayName)"
        } else if let expiry = latestExpiry {
            subscriptionStatus = SubscriptionManager.SubscriptionStatus.expired
            statusMessage = "\("Subscription expired on".localizedString) \(DateFormatter.shortDate.string(from: expiry))"
        } else {
            subscriptionStatus = SubscriptionManager.SubscriptionStatus.notSubscribed
            statusMessage = "No active subscription".localizedString
        }
    }

    // MARK: - Introductory Offer Handling

    private func checkIntroductoryOfferEligibility() async {
        for product in availableProducts {
            await checkEligibilityForIntroductoryOffer(productId: product.id)
        }
    }

    private func checkEligibilityForIntroductoryOffer(productId: String) async {
        
        var product: Product?
        
        if let productSubscription = availableProducts.first(where: { $0.id == productId }) {
            product = productSubscription
        }
        
        guard let product else { return }

        // Prefer StoreKit's built-in eligibility when available; otherwise assume eligible
        let eligible: Bool = await product.subscription?.isEligibleForIntroOffer ?? true

        await MainActor.run {
            self.introductoryOfferEligibility[productId] = eligible
        }
    }

    func getIntroductoryOfferInfo(for productId: String) -> SubscriptionManager.IntroductoryOfferInfo? {
        
        var product: Product?
        
        if let productSubscription = availableProducts.first(where: { $0.id == productId }) {
            product = productSubscription
        }
        
        guard let product,
              let offer = product.subscription?.introductoryOffer else {
            return nil
        }

        let isEligible = introductoryOfferEligibility[productId] ?? true

        let offerType: IntroductoryOfferInfo.IntroductoryOfferType = switch offer.paymentMode {
        case .freeTrial: .freeTrial
        case .payAsYouGo: .payAsYouGo
        case .payUpFront: .payUpFront
        default: .payAsYouGo
        }

        let periodString = formatSubscriptionPeriod(offer.period)

        return SubscriptionManager.IntroductoryOfferInfo(
            type: offerType,
            price: offer.price,
            priceLocale: Locale.current,
            numberOfPeriods: offer.periodCount,
            subscriptionPeriod: periodString,
            isEligible: isEligible
        )
    }

    private func formatSubscriptionPeriod(_ period: Product.SubscriptionPeriod) -> String {
        let unit: String = switch period.unit {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        @unknown default: "period"
        }
        
        if period.value == 1 {
            return unit
        } else {
            return "\(period.value) \(unit)s"
        }
    }

    // MARK: - Handle Purchase Error

    // Error mapping retained for UI messages if needed
    private func handlePurchaseErrorMessage(_ error: Error) {
        statusMessage = "Purchase failed: \(error.localizedDescription)"
    }

    func getSubscriptionStatusText() -> String {
        switch subscriptionStatus {
        case .notSubscribed:
            return "No active subscription".localizedString
        case .lifetime:
            return "Lifetime access".localizedString
        case let .subscribed(expiryDate):
            return "\("Active until".localizedString) \(DateFormatter.shortDate.string(from: expiryDate))"
        case .expired:
            return "Subscription expired".localizedString
        case .unknown:
            return "Unknown status".localizedString
        }
    }

    // MARK: - Introductory Offer Helpers

    func hasUsedIntroductoryOffer(for productId: String) -> Bool {
        !(introductoryOfferEligibility[productId] ?? true)
    }

    func getIntroductoryOfferText(for productId: String) -> LocalizedStringKey? {
        guard let introOffer = getIntroductoryOfferInfo(for: productId),
              introOffer.isEligible else {
            return nil
        }
        return introOffer.displayText
    }

    @MainActor
    func refreshIntroductoryOfferEligibility() async {
        await checkIntroductoryOfferEligibility()
    }

    // MARK: - Internal helpers

    @MainActor
    private func handleVerifiedTransaction(_ transaction: StoreKit.Transaction) async {
        // Update state based on new transaction
        if productIds.contains(transaction.productID) ||
            transaction.productID == NonConsumableProduct.lifetime.productId {
            
            // Auto-renewals also arrive as new verified transactions.
            // Log a purchase event for renewals (originalID differs from the new transaction id)
            logRenewalIfNeeded(for: transaction)
            
            await validateCurrentSubscription()
        }
    }
    
    /// Track auto-renewals through the Adjust service using the same token mapping as initial purchases.
    private func logRenewalIfNeeded(for transaction: StoreKit.Transaction) {
        guard let autoRenew = AutoRenewableSubscription(productId: transaction.productID) else { return }
        // Skip the very first purchase (originalID == id); we already log it in purchaseSubscription(...)
        guard transaction.originalID != transaction.id else { return }
        
        // Look up the product metadata to derive price & currency for the Adjust event.
        let product = availableProducts.first(where: { $0.id == transaction.productID })
        
        guard let product,
              let amount = try? NSDecimalNumber(decimal: product.price).doubleValue else { return }
        
        let currency = product.priceFormatStyle.currencyCode
        let receiptData = fetchReceiptData()
    }
    
    func fetchReceiptData() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: url)
    }
}
