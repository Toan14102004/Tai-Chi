//
//  PracticeHomeCards.swift
//  Taichi
//
//  Created by Toan Nguyen on 11/9/26.
//

import SwiftUI

/// The scrim every photo card on the Plan tab lays over its cover: clear down to `startLocation`,
/// then black to the bottom edge, the whole layer at 60 % -- Figma's linear gradient on
/// `Header Image` / `Frame 214`.
struct PhotoCardScrim: View {
    let startLocation: CGFloat

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0), location: startLocation),
                .init(color: .black, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(0.6)
    }
}

/// The white "Start now" pill at the foot of a photo card: 28 pt tall, radius 8, bold 12 pt in the
/// primary blue. A label only -- the whole card is the button.
struct CardStartButtonLabel: View {
    let title: String

    var body: some View {
        Text(title.localizedKey)
            .font(Typography.captionLarge)
            .foregroundStyle(Asset.Color.mainColor.color)
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

/// A "Daily Routine" card on the Plan tab (Figma `Frame 214`): photo edge to edge, the routine name
/// in white over the scrim, and "Start now" beneath it.
struct DailyRoutineCard: View {
    let imageUrl: URL?
    let title: String
    let action: () -> Void

    static let cardWidth: CGFloat = 210
    static let cardHeight: CGFloat = 220
    /// Auto-layout gap between cards in the carousel.
    static let cardSpacing: CGFloat = 12

    var body: some View {
        Button(action: action) {
            RemoteImageView(url: imageUrl)
                .frame(width: Self.cardWidth, height: Self.cardHeight)
                .overlay { PhotoCardScrim(startLocation: 0.46) }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(FontFamily.Inter.semiBold.font(size: 20))
                            .foregroundStyle(Asset.Color.white.color)
                            .frame(height: 28)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        CardStartButtonLabel(title: "Start now")
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                    .padding(.bottom, 12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// A "Picks for today" row on the Plan tab (Figma component `card_top weekly`): a 123 x 72 photo,
/// tagged "Free" when the workout is not premium, then the name and "Beginner - 15 min".
struct PicksWorkoutRow: View {
    let workout: WorkoutDay
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RemoteImageView(url: workout.imageUrl)
                    .frame(width: 123, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if !workout.isPremium {
                            FreeTag().padding(4)
                        }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(Typography.labelMedium)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(workout.levelDurationLabel)
                        .font(Typography.labelSmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                Spacer(minLength: 0)
            }
            .frame(height: 72)
        }
        .buttonStyle(.plain)
    }
}

/// The "Free" pill the design puts on the photo of every non-premium workout (Figma `tag`): white
/// medium 12 pt on black at 60 %.
struct FreeTag: View {
    var body: some View {
        Text("Free")
            .font(Typography.captionMedium)
            .foregroundStyle(Asset.Color.white.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.6), in: Capsule())
    }
}
