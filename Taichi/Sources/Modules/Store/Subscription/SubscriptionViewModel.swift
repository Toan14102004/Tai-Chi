//
//  SubscriptionViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/9/25.
//

import Foundation
import StoreKit
import SwiftUI

extension SubscriptionView {
    
    enum SubscriptionEntryPoint: String, Codable, Hashable {
        case onboarding
        case onboardingSecond = "onboarding_second"
        case home
        case library
        case settings
        case taichiInfo
        case discover
        
        var trackImpressionName: String {
            switch self {
            case .onboarding:
                "PW_Onboarding_impression"
            case .onboardingSecond:
                "PW_Onboarding_second_impression"
            case .home:
                "PW_Home_impression"
            case .settings:
                "PW_Settings_impression"
            case .library:
                "PW_Library_impression"
            case .taichiInfo:
                "PW_Taichi_Info"
            case .discover:
                "PW_Discover_impression"
            }
        }
        
        var screenName: String {
            switch self {
            case .onboarding:
                "Premium onboarding"
            case .onboardingSecond:
                "Premium onboarding second"
            case .home:
                "Premium home"
            case .settings:
                "Premium settings"
            case .library:
                "Premium library"
            case .taichiInfo:
                "Premium Taichi Info"
            case .discover:
                "Premium discover"
            }
        }
        
        var pageName: String {
            switch self {
            case .onboarding:
                "PremiumOnboardingVC"
            case .onboardingSecond:
                "PremiumOnboardingSecondVC"
            case .home:
                "PremiumHomeVC"
            case .settings:
                "PremiumSettingVC"
            case .library:
                "PremiumLibraryVC"
            case .taichiInfo:
                "PremiumTaichiInfoVC"
            case .discover:
                "PremiumDiscoverVC"
            }
        }
        
        var cancelEventName: String {
            switch self {
            case .onboarding:
                "PW_Onboarding_cancel"
            case .onboardingSecond:
                "PW_Onboarding_second_cancel"
            case .home:
                "PW_Home_cancel"
            case .settings:
                "PW_Settings_cancel"
            case .library:
                "PW_Library_cancel"
            case .taichiInfo:
                "PW_Taichi_Info_cancel"
            case .discover:
                "PW_Discover_cancel"
            }
        }
        
        var purchaseEventName: String {
            switch self {
            case .onboarding:
                "PW_Onboarding_buy"
            case .onboardingSecond:
                "PW_Onboarding_second_buy"
            case .home:
                "PW_Home_buy"
            case .settings:
                "PW_Settings_buy"
            case .library:
                "PW_Library_buy"
            case .taichiInfo:
                "PW_Taichi_Info_buy"
            case .discover:
                "PW_Discover_buy"
            }
        }
    }
    
    enum Description: CaseIterable {
        case unlimited
        case professional
        case removeAd
        
        var localizedDescription: LocalizedStringKey {
            switch self {
            case .unlimited:
                "Unlimited Taichi Scans"
            case .professional:
                "Professional Taichi Score"
            case .removeAd:
                "Remove Ads"
            }
        }
    }
    
    // MARK: - Plan Tab
    enum PlanTab: String, CaseIterable {
        case weekly
        case yearly
        case monthly
        
        var displayName: LocalizedStringKey {
            switch self {
            case .weekly: "Weekly"
            case .yearly: "Yearly"
            case .monthly: "Monthly"
            }
        }
        
        var planName: LocalizedStringKey {
            switch self {
            case .weekly: "Weekly Plan"
            case .yearly: "Yearly Plan"
            case .monthly: "Monthly Plan"
            }
        }
        
        var periodSuffix: String {
            switch self {
            case .weekly: "week"
            case .yearly: "year"
            case .monthly: "month"
            }
        }
        
        /// Maps to the corresponding AutoRenewableSubscription cases
        var subscriptionTypes: [AutoRenewableSubscription] {
            switch self {
            case .weekly: [.weekly, .weeklyFreeTrial]
            case .yearly: [.yearly, .yearlyFreeTrial]
            case .monthly: [.monthly, .monthlyFreeTrial]
            }
        }
    }
    
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        
        @Injected var analyticsService: AnalyticsService
        @Injected var subscriptionManager: SubscriptionManager
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator: Coordinator = .init()
        @Published var selectedProductId: String = ""
        @Published var selectedTab: PlanTab = .weekly

        let subscriptionEntryPoint: SubscriptionEntryPoint
        
        init(subscriptionEntryPoint: SubscriptionEntryPoint) {
            self.subscriptionEntryPoint = subscriptionEntryPoint
            self.selectedProductId = subscriptionManager.availableProducts.first?.id ?? ""
            updateSelectedProduct()
        }
        
        /// Updates the selectedProductId based on the currently selected tab
        func updateSelectedProduct() {
            let matchingTypes = selectedTab.subscriptionTypes
            print("🛒 [IAP] updateSelectedProduct - tab: \(selectedTab.rawValue), matchingTypes: \(matchingTypes.map { $0.rawValue })")
            print("🛒 [IAP] availableProducts count: \(subscriptionManager.availableProducts.count)")
            for p in subscriptionManager.availableProducts {
                let sub = AutoRenewableSubscription(productId: p.id)
                print("🛒 [IAP]   product: \(p.id) -> sub: \(sub?.rawValue ?? "nil")")
            }
            if let product = subscriptionManager.availableProducts.first(where: { p in
                guard let sub = AutoRenewableSubscription(productId: p.id) else { return false }
                return matchingTypes.contains(sub)
            }) {
                selectedProductId = product.id
            }
        }
        
        /// Returns the Product matching the current selectedProductId
        func selectedProduct(from availableProducts: [Product]) -> Product? {
            availableProducts.first(where: { $0.id == selectedProductId })
        }
        
        func goBack() {
            analyticsService.logEvent(name: subscriptionEntryPoint.cancelEventName)
            if subscriptionEntryPoint == .onboarding || subscriptionEntryPoint == .onboardingSecond {
                localStorageService.isFirstTimeOpenApp = false
                navigator.push(RootView.Coordinator.Navigation.content)
            } else {
                navigator.dismiss()
            }
        }
        
        func purchaseSelectedProduct() {
            guard !selectedProductId.isEmpty else { return }
            subscriptionManager.purchaseSubscription(
                productId: selectedProductId,
                onSuccess: { message in
                    DispatchQueue.main.async {
                        self.openAlertSuccess(message)
                        self.analyticsService.logEvent(
                            name: self.subscriptionEntryPoint.purchaseEventName,
                            parameters: ["productId": self.selectedProductId])
                    }
                },
                onError: openAlertError(_:)
            )
        }

        func openAlertError(_ message: String) {
            coordinator.alert = .error(title: "Error".localizedString, message: message)
        }

        func openAlertSuccess(_ message: String) {
            coordinator.alert = .success(title: "Success".localizedString, message: message)
        }

        func onSubscriptionSuccess() {
            coordinator.alert = nil
            if subscriptionEntryPoint == .onboarding || subscriptionEntryPoint == .onboardingSecond {
                localStorageService.isFirstTimeOpenApp = false
                navigator.push(RootView.Coordinator.Navigation.content)
            } else {
                navigator.dismiss()
            }
        }

        func openPrivacyPolicy() {
            if let url = URL(string: AppConfiguration.privacyUrl) {
                UIApplication.shared.open(url)
            }
        }

        func openTermsOfService() {
            if let url = URL(string: AppConfiguration.termOfUseUrl) {
                UIApplication.shared.open(url)
            }
        }

        func restorePurchases() {
            subscriptionManager.restorePurchases(
                onSuccess: { message in
                    DispatchQueue.main.async {
                        self.openAlertSuccess(message)
                    }
                },
                onError: { message in
                    DispatchQueue.main.async {
                        self.openAlertError(message)
                    }
                }
            )
        }
    }
}
