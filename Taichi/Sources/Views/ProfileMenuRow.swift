//
//  ProfileMenuRow.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct ProfileMenuRow: View {
    let icon: Image
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                icon
                    .resizable()
                    .frame(width: 40.iPad(50), height: 40.iPad(50))

                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Asset.Icon.Profile.chevronRight.image
                    .resizable()
                    .frame(width: 30.iPad(35), height: 30.iPad(35))
            }
            .padding(.vertical, Layout.Spacing.s + Layout.Spacing.xs)
            // Without this, only the icon/text/chevron's own drawn pixels are tappable -- the gaps
            // between them (and the flexible space the title's `maxWidth: .infinity` opens up)
            // silently eat taps instead of reaching the button.
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ProfileMenuCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, Layout.Spacing.m)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }
}
