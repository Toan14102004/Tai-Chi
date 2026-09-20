//
//  WorkoutScheduleView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The program's day-by-day schedule: a timeline of days grouped into phases, with the day the
/// user is on highlighted.
struct WorkoutScheduleView: View {
    @StateObject private var viewModel: ViewModel

    init(programId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(programId: programId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RemoteImageView(url: viewModel.heroImageUrl)
                        .frame(width: UIScreen.main.bounds.width,
                               height: Layout.heroHeight + UIApplication.shared.safeAreaTop)

                    HeroOverlayButton(image: Asset.Icon.ProfileSetup.backChevron, action: viewModel.back)
                        .padding(Layout.Spacing.m)
                        .padding(.top, UIApplication.shared.safeAreaTop)
                }
                .clipped()

                VStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    PreloadedNativeAdsView(adKey: .practiceCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)

                    if viewModel.isLoading, viewModel.plan == nil {
                        WorkoutScheduleSkeletonView()
                    } else if let errorMessage = viewModel.errorMessage, viewModel.plan == nil {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else if let plan = viewModel.plan {
                        overallProgress

                        ForEach(plan.phases) { phase in
                            phaseSection(phase)
                        }
                    }
                }
                .padding(Layout.Spacing.m)
            }
        }
        .ignoresSafeArea(edges: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("workoutScheduleVC")
    }

    private var overallProgress: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
            Text(viewModel.progressLabel)
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textPrimary.color)

            // The overall bar is the one place the schedule uses the secondary (purple) brand
            // colour instead of the coral used everywhere else on this screen -- per Figma
            // `2016:160` -> "Progress indicator" (#9278B5).
            progressBar(viewModel.progressFraction, height: 8, color: Asset.Color.secondaryColor.color)
        }
    }

    private func progressBar(_ fraction: Double, height: CGFloat, color: Color = Asset.Color.mainColor.color) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Asset.Color.borderPrimary.color)
                Capsule()
                    .fill(color)
                    .frame(width: max(geometry.size.width * fraction, fraction > 0 ? 6 : 0))
            }
        }
        .frame(height: height)
    }

    // MARK: - Phase

    @ViewBuilder
    private func phaseSection(_ phase: WorkoutPhase) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            // Programs the API ships without phases get no header: with a single section it would
            // just restate the progress line directly above it.
            if let number = phase.number {
                HStack(spacing: Layout.Spacing.xs) {
                    Text("Phase \(number)")
                        .font(Typography.subtitleSmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    Text(phase.name)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    Spacer()

                    // Figma only prints a percentage on the phase the user has started (`Phase 1`
                    // in `2016:160`) -- the untouched `Phase 2` header carries no trailing number.
                    let progress = viewModel.phaseProgress(phase)
                    if progress > 0 {
                        Text("\(Int(progress * 100))%")
                            .font(Typography.bodySmall)
                            .foregroundStyle(Asset.Color.textSecondary.color)
                    }
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(phase.days.enumerated()), id: \.element.id) { position, day in
                    dayRow(day,
                           showsConnector: position < phase.days.count - 1,
                           previousDay: position > 0 ? phase.days[position - 1] : nil)
                }
            }
        }
    }

    // MARK: - Day row

    private func dayRow(_ day: WorkoutDay, showsConnector: Bool, previousDay: WorkoutDay?) -> some View {
        let state = viewModel.state(for: day)
        let fraction = viewModel.dayProgress(day)

        return HStack(alignment: .top, spacing: Layout.Spacing.s) {
            timeline(state: state,
                     showsConnector: showsConnector,
                     incomingFinished: previousDay.map { viewModel.state(for: $0) == .finished })

            Button {
                viewModel.openDay(day)
            } label: {
                HStack(spacing: Layout.Spacing.s) {
                    RemoteImageView(url: day.imageUrl)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))

                    VStack(alignment: .leading, spacing: 3) {
                        // A finished day's title dims to secondary, matching the card's own
                        // "Finished!" caption -- everything else stays primary (Figma `2016:160`:
                        // Day 1's title is #58575F, Day 2/3's is #0E1329).
                        Text(day.dayNumber > 0 ? "Day \(day.dayNumber)" : day.title)
                            .font(Typography.subtitleLarge)
                            .foregroundStyle(state == .finished
                                             ? Asset.Color.textSecondary.color
                                             : Asset.Color.textPrimary.color)

                        subtitle(for: day, state: state, fraction: fraction)
                    }

                    Spacer(minLength: Layout.Spacing.xs)

                    trailing(for: state)
                }
                .padding(Layout.Spacing.s)
                // Every card is white -- only the current day additionally gets a coral border.
                .background(Asset.Color.white.color)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
                .overlay {
                    if state == .current {
                        RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                            .stroke(Asset.Color.mainColor.color, lineWidth: 1)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(day.isRestDay)
            // The gap between cards lives inside the row, not outside it, so the timeline column
            // -- which stretches to the row's height -- carries its connector across the gap.
            .padding(.bottom, 12)
        }
    }

    /// The connected circles running down the left edge -- the schedule's "critical path".
    ///
    /// `incomingFinished` is `nil` for the first day of a phase; otherwise it says whether the day
    /// above is finished, which colours the short segment that joins its connector to this dot.
    private func timeline(state: WorkoutDayState, showsConnector: Bool, incomingFinished: Bool?) -> some View {
        VStack(spacing: 0) {
            if let incomingFinished {
                connector(finished: incomingFinished)
                    .frame(height: Layout.Spacing.m)
            } else {
                Color.clear.frame(height: Layout.Spacing.m)
            }

            ZStack {
                switch state {
                case .finished:
                    Circle().fill(Asset.Color.mainColor.color)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Asset.Color.white.color)
                case .current:
                    Circle().stroke(Asset.Color.mainColor.color, lineWidth: 1.5)
                case .upcoming:
                    // `textTertiary` (#CCCCCC), not `borderPrimary` (#EAEAEA) -- the design's
                    // upcoming dot is a full step darker than the hairline colour used for
                    // dividers, so it still reads against the connector line.
                    Circle().stroke(Asset.Color.textTertiary.color, lineWidth: 1.5)
                }
            }
            .frame(width: 20, height: 20)

            if showsConnector {
                connector(finished: state == .finished)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 20)
    }

    /// Dashed, per design: mainColor once the day above is finished, matching the finished dot's
    /// colour, otherwise the same hairline grey as everywhere else.
    private func connector(finished: Bool) -> some View {
        DashedVerticalLine()
            .stroke(finished ? Asset.Color.mainColor.color : Asset.Color.borderPrimary.color,
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            .frame(width: 1)
    }

    @ViewBuilder
    private func subtitle(for day: WorkoutDay, state: WorkoutDayState, fraction: Double) -> some View {
        if day.isRestDay {
            caption("Rest day")
        } else if state == .finished {
            caption("Finished!")
        } else if fraction > 0 {
            // Started but unfinished days show how far in the user got. The percentage itself
            // is coral in the design, unlike every other caption on this row.
            HStack(spacing: Layout.Spacing.xs) {
                progressBar(fraction, height: 4).frame(width: 90)
                Text("\(Int(fraction * 100))%")
                    .font(Typography.captionMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
        } else {
            caption(day.exerciseCountLabel)
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(Typography.captionMedium)
            .foregroundStyle(Asset.Color.textSecondary.color)
    }

    @ViewBuilder
    private func trailing(for state: WorkoutDayState) -> some View {
        switch state {
        case .finished:
            Asset.Icon.Commo.checkmarkCircle.image.toIcon(Layout.Icon.medium)
        case .current:
            // Only the day the user can actually start now gets the actionable Play button --
            // days further out aren't reachable yet, so they get a plain ring instead (B_13).
            Image(systemName: "play.fill")
                .font(.system(size: 11))
                .foregroundStyle(Asset.Color.white.color)
                .frame(width: Layout.Icon.medium, height: Layout.Icon.medium)
                .background(Asset.Color.mainColor.color)
                .clipShape(Circle())
        case .upcoming:
            Circle()
                .stroke(Asset.Color.mainColor.color, lineWidth: 1.5)
                .frame(width: Layout.Icon.medium, height: Layout.Icon.medium)
        }
    }
}

/// A single vertical segment, top to bottom of its frame -- meant to be stroked with a `dash`
/// style so the timeline's connector reads as a dashed line rather than solid.
private struct DashedVerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
