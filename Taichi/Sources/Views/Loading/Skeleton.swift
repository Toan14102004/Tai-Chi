//
//  Skeleton.swift
//  Taichi
//
//  Shimmer-skeleton building blocks: flat placeholder shapes with a moving highlight sweeping
//  across them, standing in for a screen's real layout while its first API call is in flight.
//  Every `Skeleton*` screen view is built out of `SkeletonBlock`/`SkeletonCircle` only, so a
//  loading screen reads as "this layout, not yet filled in" rather than a blank spinner.
//

import SwiftUI

private struct Shimmer: ViewModifier {
    private static let period: TimeInterval = 1.4

    func body(content: Content) -> some View {
        content
            .overlay {
                TimelineView(.animation) { timeline in
                    GeometryReader { geometry in
                        let screenWidth = UIScreen.main.bounds.width
                        let bandWidth = screenWidth * 0.6
                        let elapsed = timeline.date.timeIntervalSinceReferenceDate
                        let phase = elapsed.truncatingRemainder(dividingBy: Self.period) / Self.period
                        let bandX = -bandWidth + (screenWidth + bandWidth) * phase

                        LinearGradient(
                            colors: [.clear, .white.opacity(0.35), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: bandWidth)
                        .offset(x: bandX - geometry.frame(in: .global).minX)
                    }
                }
                .allowsHitTesting(false)
            }
    }
}

/// One rectangular skeleton shape -- a stand-in for a card, an image, or a line of text. Give it
/// a `.frame(width:height:)` the way its real content would take one.
struct SkeletonBlock: View {
    var cornerRadius: CGFloat = 8

    var body: some View {
        // `gray`/`textTertiary` (#CCCCCC), not `bgSecondary` (#F2F2F2): the page background is
        // `bgPrimary` (#F4F4F4), only 2 points off bgSecondary in every channel -- a skeleton
        // filled with it is invisible rather than "not loaded yet".
        Asset.Color.gray.color
            .modifier(Shimmer())
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// A skeleton shape for an avatar or icon circle.
struct SkeletonCircle: View {
    var body: some View {
        Asset.Color.gray.color
            .modifier(Shimmer())
            .clipShape(Circle())
    }
}

/// A skeleton line the height and width of one row of text, e.g. `SkeletonLine(width: 120)` for a
/// short title. Height defaults to a `bodyMedium` line.
struct SkeletonLine: View {
    var width: CGFloat
    var height: CGFloat = 14

    var body: some View {
        SkeletonBlock(cornerRadius: height / 2.8)
            .frame(width: width, height: height)
    }
}

/// A photo-plus-two-lines row, the shape shared by `WorkoutExerciseRow`, `PicksWorkoutRow` and
/// every "Card_day"-style row across the app.
struct SkeletonPhotoRow: View {
    var photoSize: CGSize = CGSize(width: 72, height: 72)
    var photoCornerRadius: CGFloat = 12

    var body: some View {
        HStack(spacing: Layout.Spacing.s) {
            SkeletonBlock(cornerRadius: photoCornerRadius)
                .frame(width: photoSize.width, height: photoSize.height)

            VStack(alignment: .leading, spacing: 6) {
                SkeletonLine(width: 160)
                SkeletonLine(width: 90, height: 12)
            }

            Spacer(minLength: 0)
        }
    }
}
