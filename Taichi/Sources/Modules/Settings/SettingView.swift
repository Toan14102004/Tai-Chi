//
//  SettingView.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/11/24.
//

import Lottie
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager  
    @Injected var localStorageService: LocalStorageService
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        BaseView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    premiumView()
                        .padding(.top, Layout.Spacing.m)
                    
                    sectionHeader("Currency")
                        .padding(.top, Layout.Spacing.l)
                    
                    SettingRow(
                        icon: Asset.Icon.Setting.language.image,
                        title: "Change currency",
                        action: viewModel.navigateToLanguage
                    )
                    .padding(.top, Layout.Spacing.s)
                    
                    sectionHeader("Share")
                        .padding(.top, Layout.Spacing.l)
                    
                    VStack(spacing: 0) {
                        SettingRow(
                            icon: Asset.Icon.Setting.starDisable.image,
                            title: "Rate App",
                            corners: [.topLeft, .topRight],
                            action: { viewModel.showRatePopup = true }
                        )
                        Divider()
                            .background(Color.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                        
                        SettingRow(
                            icon: Asset.Icon.Setting.share.image,
                            title: "Share App",
                            corners: [.bottomLeft, .bottomRight],
                            action: viewModel.shareApp
                        )
                    }
                    .padding(.top, Layout.Spacing.s)
                    
                    sectionHeader("Terms & Privacy")
                        .padding(.top, Layout.Spacing.l)
                    
                    VStack(spacing: 0) {
                        SettingRow(
                            icon: Asset.Icon.Setting.contact.image,
                            title: "Terms & Conditions",
                            corners: [.topLeft, .topRight],
                            action: viewModel.openTermOfUse
                        )
                        
                        Divider()
                            .background(Color.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                        
                        SettingRow(
                            icon: Asset.Icon.Setting.shield.image,
                            title: "Privacy Policy",
                            corners: [.bottomLeft, .bottomRight],
                            action: viewModel.openPrivacyPolicy
                        )
                    }
                    .padding(.top, Layout.Spacing.s)
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.xxl)
            }
            .popup(item: $viewModel.coordinator.alert) { item in
                switch item {
                case let .error(title, message):
                    CustomAlertView(
                        title: LocalizedStringKey(title),
                        titleColor: .red,
                        description: LocalizedStringKey(message),
                        primaryActionTitle: "OK",
                        primaryAction: { viewModel.coordinator.alert = nil }
                    )
                case let .success(title, message):
                    CustomAlertView(
                        title: LocalizedStringKey(title),
                        description: LocalizedStringKey(message),
                        cancelActionTitle: "Cancel",
                        cancelAction: { viewModel.coordinator.alert = nil },
                        primaryActionTitle: "OK",
                        primaryAction: { viewModel.coordinator.alert = nil }
                    )
                }
            } customize: {
                $0.centerPopup()
            }
            .popup(isPresented: $viewModel.showRatePopup) {
                RateAppPopupView(
                    selectedRating: $viewModel.selectedRating,
                    showFeedback: $viewModel.showFeedback,
                    onRate: viewModel.submitRating,
                    onDismiss: { viewModel.showRatePopup = false }
                )
            } customize: {
                $0.centerPopup()
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.5))
            }
            .popup(isPresented: $viewModel.showFeedback) {
                FeedbackPopupView(
                    selectedReasons: $viewModel.selectedFeedbackReasons,
                    otherText: $viewModel.otherFeedbackText,
                    onSend: viewModel.sendFeedback,
                    onDismiss: { viewModel.showFeedback = false }
                )
            } customize: {
                $0.centerPopup()
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.5))
            }
            .popup(isPresented: $viewModel.showThankYou) {
                ThankYouPopupView()
            } customize: {
                $0.centerPopup()
                    .closeOnTapOutside(false)
                    .backgroundColor(Asset.Color.black.color.opacity(0.4))
            }
        }
            .flowDestination(for: Coordinator.FullScreen.self) { item in
                switch item {
                case .feedback: MailView(onSuccess: viewModel.onMailSentSuccess(data:), onError: viewModel.onMailSentError(error:))
                }
            }
            .flowDestination(for: Coordinator.Navigation.self) { item in
                switch item {
                case .language: LanguageView(viewModel: .init())
                case .feedback: FeedbackView()
                }
            }
            .trackScreen("settingsVC")
            .toolbar {
                BackButton {
                    viewModel.goBack()
                }
                
                ToolbarTitleSetting(firstPart: "Setting", secondPart: "")
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: { viewModel.openPremiumView() }
                    ) {
                        Asset.Icon.Setting.premium.image
                            .toIcon(Layout.Icon.medium)
                            .foregroundStyle(Asset.Color.primary.color)
                    }
                }
            }
        }
    }


// MARK: - View Helpers

private extension SettingView {
    @ViewBuilder
    func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(FontFamily.Inter.bold.font(size: Layout.Text.title3))
            .foregroundStyle(Asset.Color.white.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Layout.Spacing.xs)
    }

    @ViewBuilder
    func premiumView() -> some View {
        if !subscriptionManager.isSubscribed {
            Button {
                viewModel.openPremiumView()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                        HStack(spacing: Layout.Spacing.s) {
                            Asset.Icon.Setting.premium.image
                                .toIcon(24.iPad(28))

                            Text("Upgrade Premium")
                                .font(FontFamily.Inter.bold.font(size: Layout.Text.headline))
                                .foregroundStyle(Asset.Color.white.color)
                        }

                        Text("Unlock to get VIP features!")
                            .font(FontFamily.Inter.regular.font(size: Layout.Text.footnote))
                            .foregroundStyle(Asset.Color.white.color.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Unlock Now")
                        .font(FontFamily.Inter.bold.font(size: Layout.Text.footnote))
                        .foregroundStyle(Asset.Color.white.color)
                        .padding(.horizontal, Layout.Spacing.m)
                        .padding(.vertical, Layout.Spacing.s)
                        .overlay(
                            Capsule()
                                .stroke(Asset.Color.white.color, lineWidth: 1)
                        )
                }
                .padding(Layout.Spacing.l)
                .frame(maxWidth: .infinity)
                .background(
                    Asset.Image.Setting.imageBackground.image
                        .resizable()
                        .scaledToFill()
                )
                .cornerRadius(radius: Layout.CornerRadius.large, corners: .allCorners)
                .clipped()
            }
        }
    }
}

// MARK: - Setting Row

struct SettingRow: View {
    var icon: Image
    var title: LocalizedStringKey
    var corners: UIRectCorner = .allCorners
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Layout.Spacing.m) {
                icon.toIcon(Layout.Icon.medium)

                Text(title)
                    .font(FontFamily.Inter.regular.font(size: Layout.Text.body))
                    .foregroundStyle(Asset.Color.white.color)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .toIcon(Layout.Icon.small)
                    .foregroundStyle(Asset.Color.white.color)
                    .padding(.trailing, Layout.Spacing.m)
            }
            .padding(.leading, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Asset.Color.colorTaichi.color)
            .cornerRadius(radius: Layout.CornerRadius.large, corners: corners)
        }
    }
}

// MARK: - Rate App Popup

private struct RateAppPopupView: View {
    @Binding var selectedRating: Int
    @Binding var showFeedback: Bool
    var onRate: () -> Void
    var onDismiss: () -> Void

    private var isPositive: Bool { selectedRating >= 4 }

    var body: some View {
        VStack(spacing: Layout.Spacing.s) {
            if selectedRating == 0 || selectedRating == 4 || selectedRating == 5 {
                Asset.Icon.Setting.happy.image
                    .resizable()
                    .toIcon(65.iPad(75))
            }
            else {
                Asset.Icon.Setting.sad.image
                    .resizable()
                    .toIcon(65.iPad(75))
            }

            Text(selectedRating > 0 && !isPositive ? "Not enjoying the app?".localizedKey : "Enjoying the app?".localizedKey)
                .font(FontFamily.Inter.bold.font(size: Layout.Text.title3))
                .foregroundStyle(Asset.Color.white.color)
                .multilineTextAlignment(.center)

            Text("Your feedback will help us improve!".localizedKey)
                .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                .foregroundStyle(Asset.Color.gray.color)
                .multilineTextAlignment(.center)

            HStack {
                Text("The best rating for us".localizedKey)
                    .font(FontFamily.Inter.regular.font(size: Layout.Text.footnote))
                    .foregroundStyle(Asset.Color.gray.color)
                
                Asset.Icon.Commo.arrowRateApp.image
                    .toIcon(24.iPad(28))
                    .padding(.top, Layout.Spacing.xs)
            }

            HStack(spacing: Layout.Spacing.m) {
                ForEach(1 ... 5, id: \.self) { star in
                    (star <= selectedRating ? Asset.Icon.Setting.starEnable : Asset.Icon.Setting.starDisable)
                        .image
                        .toIcon(32)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedRating = star
                            }
                        }
                }
            }
            .padding(.bottom, Layout.Spacing.xs)

            Button {
                onRate()
            } label: {
                Text("Rate us".localizedKey)
                    .font(FontFamily.Inter.bold.font(size: Layout.Text.body))
                    .foregroundStyle(Asset.Color.white.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.Spacing.m)
                    .background(
                        Capsule()
                            .fill(selectedRating == 0 ? Color.gray.opacity(0.4) : Color(hex: "#FF6B00"))
                    )
            }
            .disabled(selectedRating == 0)

            // Maybe later
            Button {
                onDismiss()
            } label: {
                Text("Maybe later".localizedKey)
                    .font(FontFamily.Inter.bold.font(size: Layout.Text.body))
                    .foregroundStyle(Asset.Color.gray.color)
            }
        }
        .padding(Layout.Spacing.xl)
        .background(Asset.Color.colorTaichi.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
        .padding(.horizontal, Layout.Spacing.l)
    }
}

// MARK: - Feedback Popup

private struct FeedbackPopupView: View {
    @Binding var selectedReasons: Set<String>
    @Binding var otherText: String
    var onSend: () -> Void
    var onDismiss: () -> Void

    private let reasons = [
        "App crashes",
        "Slow performance on older devices",
        "Too many ads",
        "App font is hard to read",
        "Limited app functionality",
        "Others"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            Text("Tell me what affected your experience:".localizedKey)
                .font(FontFamily.Inter.bold.font(size: Layout.Text.subheadline))
                .foregroundStyle(Asset.Color.white.color)
                .padding(.bottom, Layout.Spacing.xs)

            ForEach(reasons, id: \.self) { reason in
                let isSelected = selectedReasons.contains(reason)
                Button {
                    withAnimation {
                        if isSelected {
                            selectedReasons.remove(reason)
                        } else {
                            selectedReasons.insert(reason)
                        }
                    }
                } label: {
                    HStack(spacing: Layout.Spacing.m) {
                        ZStack {
                            RoundedRectangle(cornerRadius: Layout.CornerRadius.small + 2)
                                .stroke(isSelected ? Color(hex: "#FF6B00") : Asset.Color.white.color.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 20.iPad(25), height: 20.iPad(25))

                            if isSelected {
                                RoundedRectangle(cornerRadius: Layout.CornerRadius.small + 2)
                                    .fill(Color(hex: "#FF6B00"))
                                    .frame(width: 20.iPad(25), height: 20.iPad(25))

                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Asset.Color.white.color)
                            }
                        }

                        Text(reason.localizedKey)
                            .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                            .foregroundStyle(Asset.Color.white.color)

                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }

            // Text Editor for "Others"
            if selectedReasons.contains("Others") {
                TextEditor(text: $otherText)
                    .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                    .foregroundStyle(Asset.Color.white.color)
                    .padding(Layout.Spacing.m)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .scrollContentBackground(.hidden)
                    .background(Asset.Color.gray.color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.xl))
                    .overlay(
                        Group {
                            if otherText.isEmpty {
                                Text("Start your feedback here".localizedKey)
                                    .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                                    .foregroundStyle(Asset.Color.gray.color.opacity(0.6))
                                    .padding(.horizontal, Layout.Spacing.m + 4)
                                    .padding(.vertical, Layout.Spacing.m + 8)
                            }
                        },
                        alignment: .topLeading
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.CornerRadius.xl)
                            .stroke(Asset.Color.gray.color.opacity(0.3), lineWidth: 1)
                    )
            }

            Button {
                onSend()
            } label: {
                Text("Send".localizedKey)
                    .font(FontFamily.Inter.bold.font(size: Layout.Text.body))
                    .foregroundStyle(Asset.Color.white.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.Spacing.m)
                    .background(
                        Capsule()
                            .fill(selectedReasons.isEmpty ? Color.gray.opacity(0.4) : Color(hex: "#FF6B00"))
                    )
            }
            .disabled(selectedReasons.isEmpty)
            .padding(.top, Layout.Spacing.s)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .padding(Layout.Spacing.xl)
        .background(Asset.Color.colorTaichi.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.xl))
        .padding(.horizontal, Layout.Spacing.l)
    }
}

// MARK: - Thank You Popup

private struct ThankYouPopupView: View {
    var body: some View {
        VStack(spacing: Layout.Spacing.m) {
            Asset.Icon.Setting.thankFeedback.image
                .resizable()
                .scaledToFit()
                .frame(width: 70.iPad(85))
            
            Text("Thanks for your feedback".localizedKey)
                .font(FontFamily.Inter.bold.font(size: Layout.Text.subheadline))
                .foregroundStyle(Color(hex: "#FF6B00"))
                .multilineTextAlignment(.center)
        }
        .padding(Layout.Spacing.xl)
        .background(Asset.Color.colorTaichi.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.xl))
        .padding(.horizontal, Layout.Spacing.l)
    }
}

// MARK: - Toolbar

struct ToolbarTitleSetting: ToolbarContent {
    var firstPart: LocalizedStringKey = "Send"
    var secondPart: LocalizedStringKey = "Feedback"

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: Layout.Spacing.xxs) {
                Text(firstPart)
                    .foregroundStyle(Asset.Color.white.color)

                Text(secondPart)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
            .font(FontFamily.Inter.bold.font(size: Layout.Text.title3))
        }
    }
}

#Preview {
    SettingView(viewModel: .init())
        .preview()
}
