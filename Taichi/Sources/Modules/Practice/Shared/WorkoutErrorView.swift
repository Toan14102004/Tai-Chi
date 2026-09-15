//
//  WorkoutErrorView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// Shown when a Practice screen has nothing to display because its API call failed.
struct WorkoutErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: Layout.Spacing.m) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(Asset.Color.textSecondary.color)

            Text(message)
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .multilineTextAlignment(.center)

            Button("Try again", action: retry)
                .font(Typography.labelMedium)
                .foregroundStyle(Asset.Color.white.color)
                .padding(.horizontal, Layout.Spacing.l)
                .padding(.vertical, Layout.Spacing.s)
                .background(Asset.Color.mainColor.color)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.Spacing.xxl)
    }
}
