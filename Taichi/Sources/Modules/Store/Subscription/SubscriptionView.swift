//
//  SubscriptionView.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/6/25.
//

import Foundation
import StoreKit
import SwiftUI

struct SubscriptionView: View {
    @Injected var analyticsService: AnalyticsService
    @Injected var localStorageService: LocalStorageService
    @Injected var adsManager: AdsManager

    @Navigation var navigator

    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject var viewModel: ViewModel

    @State private var canClose: Bool = false
    @State private var countdown: Int = 1 * 3600 + 32 * 60 + 12
    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let subscriptionEntryPoint: SubscriptionEntryPoint

    /// Plan cards are always shown in this order, independent of `PlanTab`'s declaration order.
    private let displayOrder: [PlanTab] = [.weekly, .monthly, .yearly]

    init(subscriptionEntryPoint: SubscriptionEntryPoint) {
        self.subscriptionEntryPoint = subscriptionEntryPoint
        self._viewModel = StateObject(
            wrappedValue: ViewModel(subscriptionEntryPoint: subscriptionEntryPoint)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection()
                dealCard()
                    .padding(.horizontal, Layout.Spacing.s)
                    .padding(.top, Layout.Spacing.m)
                planList()
                    .padding(.horizontal, Layout.Spacing.m)
                    .padding(.top, Layout.Spacing.m)
                legalSection()
                    .padding(.horizontal, Layout.Spacing.m)
                    .padding(.top, Layout.Spacing.xs)
                    .padding(.bottom, Layout.Spacing.l)
            }
        }
        .safeAreaInset(edge: .bottom) { bottomBar() }
        .background(Asset.Color.white.color)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topTrailing) {
            Button(action: viewModel.goBack) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Circle().fill(.black.opacity(0.25)))
            }
            .padding(.bottom, Layout.Spacing.s)
            .padding(.trailing, Layout.Spacing.m)
            .opacity(canClose ? 1 : 0)
            .allowsHitTesting(canClose)
        }
        .popup(item: $viewModel.coordinator.alert) { item in
            switch item {
            case .error(let title, let message):
                CustomAlertView(
                    title: LocalizedStringKey(title),
                    titleColor: .red,
                    description: LocalizedStringKey(message),
                    primaryActionTitle: "OK",
                    primaryAction: {
                        viewModel.coordinator.alert = nil
                    }
                )

            case .success(let title, let message):
                CustomAlertView(
                    title: LocalizedStringKey(title),
                    titleColor: Asset.Color.mainColor.color,
                    description: LocalizedStringKey(message),
                    primaryActionTitle: "OK",
                    primaryAction: viewModel.onSubscriptionSuccess
                )
            }
        } customize: {
            $0.centerPopup()
        }
        .popup(
            isPresented: $subscriptionManager.isLoading,
            view: {
                LoadingView(isLoading: $subscriptionManager.isLoading)
            },
            customize: {
                $0.centerPopup()
                    .closeOnTapOutside(false)
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    canClose = true
                }
            }
        }
        .onReceive(countdownTimer) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
        .trackImpression(subscriptionEntryPoint.trackImpressionName)
        .trackScreen(
            subscriptionEntryPoint.screenName, parameters: ["page_name": subscriptionEntryPoint.pageName]
        )
    }
}

// MARK: - Hero + Countdown

private extension SubscriptionView {
    /// Figma spec: 499pt hero on an 837pt artboard ≈ 59.6% of screen height.
    var heroHeight: CGFloat {
        UIScreen.main.bounds.height * 0.275
    }

    func heroSection() -> some View {
        ZStack(alignment: .bottom) {
            Asset.Image.paywallBg.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: heroHeight, alignment: .bottom)
                .clipped()

            VStack(alignment: .center, spacing: Layout.Spacing.s) {
                VStack(alignment: .center, spacing: 4) {
                    Text("⏰ Offer ends in")
                        .font(FontFamily.Inter.regular.font(size: 14))
                    Text("Go Unlimited")
                        .font(FontFamily.Inter.bold.font(size: 24))
                }
                .foregroundStyle(.white)

                HStack(spacing: 20) {
                    countdownBox(value: countdown / 3600, label: "Hours")
                    Text(":").font(FontFamily.Inter.bold.font(size: 24)).foregroundStyle(.white)
                    countdownBox(value: (countdown / 60) % 60, label: "Minutes")
                    Text(":").font(FontFamily.Inter.bold.font(size: 24)).foregroundStyle(.white)
                    countdownBox(value: countdown % 60, label: "Seconds")
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.bottom, Layout.Spacing.s)
        }
    }

    func countdownBox(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(FontFamily.Inter.bold.font(size: 28))
                .foregroundStyle(Color(hex: "#EE502F"))
                .frame(width: 48, height: 48)
                .background(Asset.Color.white.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(label)
                .font(FontFamily.Inter.regular.font(size: 12))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Bonus Deal Card

private extension SubscriptionView {
    func dealCard() -> some View {
        ZStack(alignment: .leading) {
            Asset.Image.Premium.premiumBanner.image
                .resizable()
                .aspectRatio(contentMode: .fill)

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Claim your bonus deal")
                        .font(FontFamily.Inter.bold.font(size: 18))

                    Text("Unlock everything with an exclusive limited-time offer.")
                        .font(FontFamily.Inter.regular.font(size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, Layout.Spacing.xxxl)
                }
                .foregroundStyle(Color(hex: "#1A203B"))

                HStack(spacing: 8) {
                    dealFeaturePill(icon: Asset.Icon.Iap.unlock.image, text: "Unlock all features")
                    dealFeaturePill(icon: Asset.Icon.Iap.noAds.image, text: "No ads experience")
                }
            }
            .padding(Layout.Spacing.m)
            .padding(.leading, Layout.Spacing.s)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Asset.Color.white.color, lineWidth: 1)
        )
    }

    func dealFeaturePill(icon: Image, text: String) -> some View {
        HStack(spacing: 4) {
           icon
                .toIcon(Layout.Icon.small)
            
            Text(text)
                .font(.system(size: 12))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FF7438"), Color(hex: "#FFA600")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Plan List

private extension SubscriptionView {
    @ViewBuilder
    func planList() -> some View {
        VStack(spacing: 16) {
            ForEach(displayOrder, id: \.self) { tab in
                planCard(for: tab)
            }
        }

        Button(action: viewModel.goBack) {
            Text("Use basic version")
                .font(FontFamily.Inter.medium.font(size: 12))
                .foregroundStyle(Color(hex: "#8E9EAD"))
        }
        .padding(.top, Layout.Spacing.s)
    }

    func product(for tab: PlanTab) -> Product? {
        subscriptionManager.availableProducts.first { p in
            guard let sub = AutoRenewableSubscription(productId: p.id) else { return false }
            return tab.subscriptionTypes.contains(sub)
        }
    }

    func hasFreeTrial(_ product: Product?) -> Bool {
        guard let product else { return false }
        guard let info = subscriptionManager.getIntroductoryOfferInfo(for: product.id),
              info.isEligible, case .freeTrial = info.type
        else { return false }
        return true
    }

    @ViewBuilder
    func planCard(for tab: PlanTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        let product = product(for: tab)
        let trial = hasFreeTrial(product)

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedTab = tab
                viewModel.updateSelectedProduct()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(tab.planName)
                            .font(FontFamily.Inter.semiBold.font(size: 14))
                            .foregroundStyle(Color(hex: "#1A203B"))

                        if tab != .weekly {
                            Text("Save 50%")
                                .font(FontFamily.Inter.regular.font(size: 10))
                                .foregroundStyle(Color(hex: "#008C7B"))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#D2FAF5"))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    if trial {
                        Text("Pay $0 today")
                            .font(FontFamily.Inter.medium.font(size: 12))
                            .foregroundStyle(Color(hex: "#008C7B"))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 0) {
                        Text((product?.displayPrice ?? "---") + "/")
                            .font(FontFamily.Inter.semiBold.font(size: 14))
                            .foregroundStyle(Color(hex: "#1E2429"))
                    }
                    Text(tab.periodSuffix.capitalized)
                        .font(FontFamily.Inter.regular.font(size: 10))
                        .foregroundStyle(Color(hex: "#8E9EAD"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 64)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "#008C7B") : Color(hex: "#D1D4E1"), lineWidth: isSelected ? 1.5 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Text("Best value")
                        .font(FontFamily.Inter.medium.font(size: 10))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#008C7B"))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .offset(x: -8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Legal

private extension SubscriptionView {
    func legalSection() -> some View {
        VStack(spacing: 4) {
            Text("By tapping Continue, your payment will be charged to your account and your subscription will automatically renew for the same package length at the same price until you cancel it from your device's subscription settings.")
                .font(FontFamily.Inter.regular.font(size: 8))
                .foregroundStyle(Color(hex: "#8E9EAD"))
                .multilineTextAlignment(.leading)

            HStack(spacing: 48) {
                Button(action: viewModel.openTermsOfService) {
                    Text("Terms of Use")
                }
                Button(action: viewModel.restorePurchases) {
                    Text("Restore")
                }
                Button(action: viewModel.openPrivacyPolicy) {
                    Text("Privacy Policy")
                }
            }
            .font(FontFamily.Inter.regular.font(size: 10))
            .foregroundStyle(Color(hex: "#8E9EAD"))
        }
    }
}

// MARK: - Bottom Bar

private extension SubscriptionView {
    @ViewBuilder
    func bottomBar() -> some View {
        let product = viewModel.selectedProduct(from: subscriptionManager.availableProducts)
        let subscription = product.flatMap { AutoRenewableSubscription(productId: $0.id) }
        let trial = hasFreeTrial(product)

        VStack(spacing: 12) {
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Due today")
                        .font(FontFamily.Inter.regular.font(size: 12))
                        .foregroundStyle(Color(hex: "#8E9EAD"))
                    Text(trial ? "$ 0.00" : (product?.displayPrice ?? "---"))
                        .font(FontFamily.Inter.bold.font(size: 20))
                        .foregroundStyle(Color(hex: "#EE4D2D"))
                }

                Button(action: viewModel.purchaseSelectedProduct) {
                    Text("Try now")
                        .font(FontFamily.Inter.semiBold.font(size: 14))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FF7427"), Color(hex: "#FF0202")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(Color(hex: "#008C7B"))
                    .font(.system(size: 12))
                Text(trial
                    ? "3 days free, then \(product?.displayPrice ?? "---")/\(periodUnit(subscription)). Auto-renews until canceled."
                    : "Auto renewable. Cancel anytime")
                    .font(FontFamily.Inter.medium.font(size: 10))
                    .foregroundStyle(Color(hex: "#1E2429"))
                Spacer()
            }

            if trial {
                Text("3 days free trial")
                    .font(FontFamily.Inter.medium.font(size: 8))
                    .foregroundStyle(Color(hex: "#803D1F"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "#FFDAB7"))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.vertical, Layout.Spacing.m)
        .background(Asset.Color.white.color)
    }

    func periodUnit(_ subscription: AutoRenewableSubscription?) -> String {
        switch subscription {
        case .yearly, .yearlyFreeTrial: return "year"
        case .monthly, .monthlyFreeTrial: return "month"
        case .weekly, .weeklyFreeTrial: return "week"
        case .none: return "period"
        }
    }
}

#Preview {
    SubscriptionView(subscriptionEntryPoint: .home)
        .preview()
        .environmentObject(SubscriptionManager())
}
