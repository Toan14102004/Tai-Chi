//
//  DiscoverCards.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// Section title plus the coral "View all" link, above every Discover carousel.
struct SectionHeaderRow: View {
    let title: String
    /// Optional so a header can stand without a link; every Discover section passes one.
    var viewAll: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(Typography.subtitleSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .lineLimit(1)

            Spacer(minLength: Layout.Spacing.s)

            if let viewAll {
                Button("View all", action: viewAll)
                    .font(Typography.labelSmall)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
        }
    }
}

/// A card in a Discover carousel: photo on top, then the workout name and its "Level · N min"
/// caption on the page background.
struct DiscoverWorkoutCard: View {
    let workout: WorkoutDay
    let action: () -> Void

    static let cardWidth: CGFloat = 240
    /// Auto-layout gap between cards in the carousel.
    static let cardSpacing: CGFloat = 16

    private static let photoHeight: CGFloat = 140

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                RemoteImageView(url: workout.imageUrl)
                    .frame(width: Self.cardWidth, height: Self.photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if !workout.isPremium {
                            FreeTag().padding(8)
                        }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(Typography.labelMedium)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)

                    Text(workout.levelDurationLabel)
                        .font(Typography.labelSmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }
            .frame(width: Self.cardWidth, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

/// The full-width card the category screen stacks: the same content as `DiscoverWorkoutCard` with
/// the photo running the width of the content column.
struct DiscoverListCard: View {
    let workout: WorkoutDay
    let action: () -> Void

    private static let photoHeight: CGFloat = 180

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                RemoteImageView(url: workout.imageUrl)
                    .frame(height: Self.photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

/// A card in the untitled carousel under Discover's first ad (Figma `Frame 214`, 240 x 251): a
/// recently practised workout, photo edge to edge under the dark scrim, "Free" top-left, and the
/// name, "8 min - 8 session" and a play button along the bottom.
struct DiscoverFeaturedCard: View {
    let workout: WorkoutDay
    let action: () -> Void

    static let cardWidth: CGFloat = 240
    static let cardHeight: CGFloat = 251
    /// Auto-layout gap between cards in the carousel.
    static let cardSpacing: CGFloat = 16

    var body: some View {
        Button(action: action) {
            RemoteImageView(url: workout.imageUrl)
                .frame(width: Self.cardWidth, height: Self.cardHeight)
                .overlay { PhotoCardScrim(startLocation: 0.46) }
                .overlay(alignment: .topLeading) {
                    if !workout.isPremium {
                        FreeTag()
                            .padding(.top, 11)
                            .padding(.leading, 12)
                    }
                }
                .overlay(alignment: .bottom) { footer }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        HStack(spacing: Layout.Spacing.s) {
            VStack(alignment: .leading, spacing: 0) {
                Text(workout.title)
                    .font(FontFamily.Inter.semiBold.font(size: 20))
                    .frame(height: 28)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(workout.netDurationMinutes) min - \(workout.displayExerciseCount) session")
                    .font(Typography.bodySmall)
                    .frame(height: 20)
            }
            .foregroundStyle(Asset.Color.white.color)

            Spacer(minLength: 0)

            // Figma `button`: a 28 pt white disc with the play glyph in the primary blue.
            Image(systemName: "play.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Asset.Color.mainColor.color)
                .offset(x: 1)
                .frame(width: 28, height: 28)
                .background(Asset.Color.white.color, in: Circle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
    }
}

/// An exercise row of a workout the user has not unlocked: no name, no photo, just its position
/// and a padlock. What is being withheld is the content, not the fact that the workout has one.
struct LockedExerciseRow: View {
    let position: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Asset.Icon.Discover.lockBlack.image
                    .toIcon(24)
                    .frame(width: 64, height: 64)
                    .background(Color(hex: "#CCC7C4"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("Exercise \(position)")
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.s)
            .overlay(alignment: .bottom) {
                Asset.Color.borderPrimary.color.frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

/// The "Recent" card at the top of Discover: the plan the user has under way, the day they are on,
/// and how far through the plan they are.
struct RecentPlanCard: View {
    let imageUrl: URL?
    let title: String
    let subtitle: String
    let progress: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RemoteImageView(url: imageUrl)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(Typography.subtitleSmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    HStack(spacing: 12) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Asset.Color.borderPrimary.color)
                                Capsule()
                                    .fill(Asset.Color.mainColor.color)
                                    .frame(width: max(geometry.size.width * progress,
                                                      progress > 0 ? 8 : 0))
                            }
                        }
                        .frame(height: 8)

                        Text("\(Int((progress * 100).rounded()))%")
                            .font(Typography.captionMedium)
                            .foregroundStyle(Asset.Color.mainColor.color)
                    }
                    .padding(.top, Layout.Spacing.xs)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Asset.Color.textTertiary.color)
                    .frame(width: 24, height: 24)
            }
            .padding(.leading, Layout.Spacing.s)
            .padding(.vertical, Layout.Spacing.s)
            .padding(.trailing, Layout.Spacing.m)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// Back button plus a serif screen title, for the Discover screens that push without a hero photo.
struct DiscoverNavigationBar: View {
    let title: String
    let back: () -> Void

    var body: some View {
        HStack(spacing: Layout.Spacing.s) {
            Button(action: back) {
                // `Commo.arrowLeft` is a white PNG meant for the dark scrim over a hero photo; on
                // this screen's cream background it is invisible. `backChevron` is the dark one.
                Asset.Icon.ProfileSetup.backChevron.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }

            Text(title.localizedKey)
                .font(Typography.subtitleLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(height: Layout.Button.height)
        .padding(.horizontal, Layout.Spacing.m)
    }
}
