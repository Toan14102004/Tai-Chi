//
//  GeneratingPlanStepView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import Lottie
import SwiftUI

struct GeneratingPlanStepView: View {
    let errorMessage: String?
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Layout.Spacing.xl) {
                VStack(spacing: Layout.Spacing.s) {
                    Text(ProfileSetupStep.generatingPlan.title.localizedKey)
                        .font(Typography.headlineMedium)
                        .lineSpacing(3)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .multilineTextAlignment(.center)

                    if let subtitle = ProfileSetupStep.generatingPlan.subtitle {
                        Text(subtitle.localizedKey)
                            .font(Typography.bodySmall)
                            .foregroundStyle(Asset.Color.textSecondary.color)
                            .multilineTextAlignment(.center)
                    }
                }

                if let errorMessage {
                    VStack(spacing: Layout.Spacing.m) {
                        Text(errorMessage)
                            .font(Typography.bodySmall)
                            .foregroundStyle(Color(hex: "EB4646"))
                            .multilineTextAlignment(.center)

                        PrimaryButton(title: "Try again", systemIcon: nil, action: retry)
                            .frame(width: 177)
                    }
                } else {
                    LottieView(animation: .named("Sparkles_Loop_Loader.json"))
                        .looping()
                        .frame(width: 180, height: 180)

                    Text("This may take a few moments…")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.mainColor.color)
                }
            }
            .padding(.horizontal, Layout.Spacing.l)

            Spacer()

            if let adKey = ProfileSetupStep.generatingPlan.compactAdKey {
                PreloadedNativeAdsView(adKey: adKey, style: .banner, height: NativeAdViewStyle.banner.height)
                    .padding(.horizontal, Layout.Spacing.m)
                    .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
    }
}
