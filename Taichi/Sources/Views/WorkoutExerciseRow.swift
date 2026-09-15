//
//  WorkoutExerciseRow.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// Thumbnail + name + duration row, shared by the Workout Day exercise list and
/// (in a simpler form) the 30-Day Schedule's day list.
struct WorkoutExerciseRow: View {
    let imageUrl: URL?
    let title: String
    let subtitle: String
    var isCompleted: Bool = false
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: Layout.Spacing.s) {
                RemoteImageView(url: imageUrl)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(2)
                    Text(subtitle)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                Spacer()

                if isCompleted {
                    Asset.Icon.Commo.checkmarkCircle.image
                        .toIcon(Layout.Icon.large)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
