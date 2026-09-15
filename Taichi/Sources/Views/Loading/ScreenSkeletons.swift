//
//  ScreenSkeletons.swift
//  Taichi
//
//  One skeleton view per screen shape, shown while that screen's first API call is still in
//  flight. Every one mirrors its real screen's section order and sizes closely enough that
//  content "snaps into" the same layout once it loads.
//

import SwiftUI

// MARK: - Plan tab

/// `PracticeHomeView`: Your Plan hero, the ad, Daily Routine, Picks for today.
struct PlanHomeSkeletonView: View {
    var body: some View {
        // Exactly one padding call, on the whole thing, rather than one per row -- with several
        // rows each carrying their own `.padding(.horizontal, m)` it was too easy for one to end
        // up missing or doubled and throw that row out of line with the rest.
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            section(titleWidth: 80) {
                HStack(spacing: PlanHeroCard.cardSpacing) {
                    SkeletonBlock(cornerRadius: 16)
                        .frame(width: PlanHeroCard.cardWidth, height: PlanHeroCard.cardHeight)
                }
            }

            SkeletonBlock(cornerRadius: 16)
                .frame(height: NativeAdViewStyle.contentCard.height)

            section(titleWidth: 110) {
                HStack(spacing: DailyRoutineCard.cardSpacing) {
                    ForEach(0..<2, id: \.self) { _ in
                        SkeletonBlock(cornerRadius: 16)
                            .frame(width: DailyRoutineCard.cardWidth, height: DailyRoutineCard.cardHeight)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SkeletonLine(width: 130, height: 18)

                VStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        SkeletonPhotoRow(photoSize: CGSize(width: 123, height: 72))
                    }
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }

    private func section(titleWidth: CGFloat, @ViewBuilder carousel: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonLine(width: titleWidth, height: 18)
            carousel()
        }
    }
}

// MARK: - Discover tab

/// `DiscoverHomeView`: the ad, the untitled featured carousel, then goal-section carousels.
struct DiscoverHomeSkeletonView: View {
    var body: some View {
        // Exactly one padding call, on the whole thing -- see PlanHomeSkeletonView's comment.
        VStack(alignment: .leading, spacing: 15) {
            SkeletonBlock(cornerRadius: 16)
                .frame(height: NativeAdViewStyle.contentCard.height)

            HStack(spacing: DiscoverFeaturedCard.cardSpacing) {
                ForEach(0..<2, id: \.self) { _ in
                    SkeletonBlock(cornerRadius: 16)
                        .frame(width: DiscoverFeaturedCard.cardWidth, height: DiscoverFeaturedCard.cardHeight)
                }
            }

            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonLine(width: 150, height: 18)

                    HStack(spacing: DiscoverWorkoutCard.cardSpacing) {
                        ForEach(0..<2, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 4) {
                                SkeletonBlock(cornerRadius: 12)
                                    .frame(width: DiscoverWorkoutCard.cardWidth, height: 140)
                                SkeletonLine(width: 150)
                                SkeletonLine(width: 90, height: 12)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }
}

// MARK: - Daily Routine / Picks-style session lists

/// `DailyRoutineView`'s title-and-session-list body -- the hero photo already has its own
/// placeholder via `RemoteImageView`, so this covers everything below it.
struct DailyRoutineSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            VStack(alignment: .leading, spacing: 4) {
                SkeletonLine(width: 180, height: 24)
                SkeletonLine(width: 90)
            }

            VStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonPhotoRow(photoSize: CGSize(width: 123, height: 72))
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }
}

// MARK: - Workout Day / Discover Workout detail

/// The content column under `WorkoutDayView`/`DiscoverWorkoutView`'s hero: title, a stats row,
/// then the exercise list.
struct WorkoutDetailSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            VStack(alignment: .leading, spacing: 6) {
                SkeletonLine(width: 140, height: 28)
                SkeletonLine(width: 100)
            }

            HStack(spacing: Layout.Spacing.m) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonBlock(cornerRadius: 12)
                        .frame(height: 56)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SkeletonLine(width: 130)

                VStack(spacing: Layout.Spacing.s) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonPhotoRow()
                    }
                }
            }
        }
    }
}

// MARK: - Workout Schedule

/// `WorkoutScheduleView`: the overall progress bar, then phases of day rows.
struct WorkoutScheduleSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.l) {
            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                SkeletonLine(width: 120)
                SkeletonBlock(cornerRadius: 4).frame(height: 8)
            }

            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                    SkeletonLine(width: 140)

                    VStack(spacing: Layout.Spacing.m) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonPhotoRow(photoSize: CGSize(width: 44, height: 44), photoCornerRadius: 8)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Discover category

/// `DiscoverCategoryView`'s full-width list of `DiscoverListCard`s.
struct DiscoverCategorySkeletonView: View {
    var body: some View {
        VStack(spacing: Layout.Spacing.l) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                    SkeletonBlock(cornerRadius: 12)
                        .frame(height: 180)
                    SkeletonLine(width: 200)
                    SkeletonLine(width: 110, height: 12)
                }
            }
        }
    }
}

// MARK: - Progress tab

/// `ProgressHomeView`: the calories card, the ad, the daily-activities card, two chart blocks.
struct ProgressHomeSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                SkeletonLine(width: 110)
                SkeletonLine(width: 140, height: 26)
                SkeletonBlock(cornerRadius: 4).frame(height: 8)
            }
            .padding(Layout.Spacing.m)
            .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            SkeletonBlock(cornerRadius: 16)
                .frame(height: NativeAdViewStyle.contentCard.height)

            VStack(alignment: .leading, spacing: Layout.Spacing.m) {
                SkeletonLine(width: 100)
                SkeletonBlock(cornerRadius: 12).frame(height: 140)
            }
            .padding(Layout.Spacing.m)
            .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                    SkeletonLine(width: 90)
                    SkeletonBlock(cornerRadius: 12).frame(height: 140)
                }
            }
        }
    }
}

/// `ProgressActivityTypeView`'s plain icon-and-label rows.
struct ProgressActivityTypeSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { _ in
                HStack(spacing: Layout.Spacing.m) {
                    SkeletonBlock(cornerRadius: Layout.CornerRadius.small)
                        .frame(width: 40, height: 36)
                    SkeletonLine(width: 140)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, Layout.Spacing.s)
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }
}
