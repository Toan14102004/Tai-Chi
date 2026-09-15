//
//  ProfileNavBar.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// The 60pt header shared by every screen in the Profile flow: optional back chevron,
/// a headline title, and a trailing slot (streak pill on the tab root, filter + crown elsewhere).
struct ProfileNavBar<Trailing: View>: View {
    let title: String
    var onBack: (() -> Void)?
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: Layout.Spacing.m) {
            HStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                if let onBack {
                    Button(action: onBack) {
                        Asset.Icon.ProfileSetup.backChevron.image
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }

                Text(title)
                    .font(Typography.headlineSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing
        }
        .frame(height: 60)
        .padding(.horizontal, Layout.Spacing.m)
    }
}

extension ProfileNavBar where Trailing == EmptyView {
    init(title: String, onBack: (() -> Void)? = nil) {
        self.init(title: title, onBack: onBack) { EmptyView() }
    }
}
