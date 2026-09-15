//
//  PremiumAccessCard.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct PremiumAccessCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: Layout.Spacing.s) {
                            Asset.Icon.Profile.premiumSparkle.image
                                .resizable()
                                .frame(width: 20, height: 20)

                            Text("Premium Access")
                                .font(Typography.headlineMedium)
                                .foregroundStyle(Asset.Color.white.color)
                        }

                        Text("Join Pro to enjoy all the benefits")
                            .font(FontFamily.Inter.regular.font(size: 12))
                            .foregroundStyle(Asset.Color.white.color)
                    }

                    Text("Try Premium")
                        .font(FontFamily.Inter.bold.font(size: 12))
                        .foregroundStyle(Asset.Color.mainColor.color)
                        .padding(.horizontal, Layout.Spacing.m)
                        .padding(.vertical, Layout.Spacing.s)
                        .background(Asset.Color.black.color)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Asset.Icon.Profile.crownPremium.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 116)
            }
            .padding(Layout.Spacing.m)
            .frame(height: 120)
            .background(AppGradient.premiumCard)
            .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }
}
