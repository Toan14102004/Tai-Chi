//
//  WorkoutUnlockDialog.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// The "Unlock This Workout" popup: the only way into a Discover workout's exercise list.
///
/// Both routes out of it unlock the same thing -- a rewarded ad unlocks this one workout,
/// a subscription unlocks every workout -- so the copy sells the difference rather than the
/// action.
struct WorkoutUnlockDialog: View {
    let getPremium: () -> Void
    let watchAds: () -> Void
    let close: () -> Void

    var body: some View {
        VStack(spacing: Layout.Spacing.m) {
            HStack {
                Spacer()
                Button(action: close) {
                    // `Asset.Icon.Commo.xmark` is a white glyph for dark sheets; on this white
                    // card it disappears.
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }

            Text("Unlock This Workout")
                .font(Typography.subtitleLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)

            Text("Watch a short ad to download this workout, or enjoy unlimited downloads and a completely ad-free experience.")
                .font(Typography.bodySmall)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: Layout.Spacing.s) {
                Button(action: getPremium) {
                    label(icon: Asset.Icon.Discover.jewelry.image.toIcon(Layout.Icon.small).eraseToAnyView(),
                          title: "Get Premium",
                          color: Asset.Color.white.color)
                        .background(Asset.Color.mainColor.color)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
                }

                Button(action: watchAds) {
                    label(icon:Asset.Icon.Discover.video.image.toIcon(Layout.Icon.small).eraseToAnyView(),
                        title: "Watch Ads",
                        color: Asset.Color.mainColor.color)
                        .overlay {
                            RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                                .stroke(Asset.Color.mainColor.color.opacity(Layout.Opacity.medium),
                                        lineWidth: 1)
                        }
                }
            }
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.xl, style: .continuous))
        .padding(.horizontal, Layout.Spacing.l)
    }

    private func label(icon: AnyView, title: String, color: Color) -> some View {
        HStack(spacing: Layout.Spacing.s) {
            icon
            Text(title.localizedKey)
                .font(Typography.bodyLarge)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.Spacing.m)
    }
}
