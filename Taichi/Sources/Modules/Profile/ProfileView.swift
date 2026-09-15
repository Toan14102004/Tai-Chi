//
//  ProfileView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject private var languageManager = LanguageManager.shared

    private func localized(_ key: String) -> String {
        _ = languageManager.currentLanguageCode
        return key.localizedString
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavBar(title: localized("profile.title")) {
                streakPill
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: Layout.Spacing.xl) {
                    identity

                    VStack(spacing: Layout.Spacing.m) {
                        if !subscriptionManager.isSubscribed {
                            PremiumAccessCard(action: viewModel.openPremium)
                        }

                        PreloadedNativeAdsView(adKey: .profileMedium, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                        ProfileMenuCard {
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuProfile.image, title: localized("profile.row.my_profile"), action: viewModel.openPersonalDetails)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuWorkoutSettings.image, title: localized("profile.row.workout_settings"), action: viewModel.openWorkoutSettings)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuReminder.image, title: localized("profile.row.reminder"), action: viewModel.openReminder)
                        }

                        ProfileMenuCard {
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuRateUs.image, title: localized("profile.row.rate_us"), action: viewModel.rateUs)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuLanguage.image, title: localized("profile.row.language"), action: viewModel.openLanguage)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuInviteFriends.image, title: localized("profile.row.invite_friends"), action: viewModel.shareApp)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuTerms.image, title: localized("profile.row.terms_of_use"), action: viewModel.openTermOfUse)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuPrivacy.image, title: localized("profile.row.privacy_policy"), action: viewModel.openPrivacyPolicy)
                        }
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                }
                .padding(.bottom, Layout.Spacing.xxl * 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear.ignoresSafeArea())
        .onAppear(perform: viewModel.reload)
        .trackScreen("profileVC")
    }

    // MARK: - Pieces

    private var streakPill: some View {
        Button(action: viewModel.openStreak) {
            HStack(spacing: Layout.Spacing.s) {
                Asset.Icon.Commo.fire.image.toIcon(Layout.Icon.medium)

                Text("\(viewModel.streakDays)")
            }
            .font(Typography.bodyLarge)
            .foregroundStyle(Asset.Color.mainColor.color)
            .padding(.horizontal, Layout.Spacing.s)
            .padding(.vertical, Layout.Spacing.xs)
            .background(Asset.Color.white.color, in: Capsule())
            .overlay(Capsule().stroke(Asset.Color.mainColor.color, lineWidth: 1))
        }
    }

    private var identity: some View {
        VStack(spacing: Layout.Spacing.s) {
            Group {
                if let image = viewModel.avatarImage {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                } else {
                    Asset.Icon.Profile.avatarPlaceholder.image.resizable().aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            Text(viewModel.profile.displayName)
                .font(Typography.headlineLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
        }
        .padding(.top, Layout.Spacing.m)
        .background(
            Asset.Image.Setting.backgroundAvatar.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
    }
}

#Preview {
    ProfileView()
        .preview()
}
