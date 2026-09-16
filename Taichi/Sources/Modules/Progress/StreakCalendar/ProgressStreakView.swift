//
//  ProgressStreakView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct ProgressStreakView: View {
    @StateObject private var viewModel = ViewModel()

    private static let weekdaySymbols = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: "Your Streak", back: viewModel.back)

            ScrollView {
                VStack(spacing: Layout.Spacing.l) {
                    Asset.Icon.Commo.yourStreak.image
                        .toIcon(110.iPad(120))

                    Text("\(viewModel.streakDays)-Day Streak !")
                        .font(Typography.headlineLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    Text("Every check-in moves your forward. Keep coming back and let your streak grow.")
                        .multilineTextAlignment(.center)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else {
                        calendar
                    }
                }
                .padding(Layout.Spacing.m)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // `2168:5690`'s frame fill: a top-to-bottom gradient fading from coral through peach
            // into the app's own cream, rather than a flat background like every other screen.
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#FE7E7A"), location: 0),
                    .init(color: Color(hex: "#FFCBA6"), location: 0.21),
                    .init(color: Asset.Color.bgPrimary.color, location: 0.41),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("progressStreakVC")
    }

    private var calendar: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(Self.monthFormatter.string(from: viewModel.month))
                    .font(Typography.headlineSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 0) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(Typography.labelSmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: Layout.Spacing.s) {
                ForEach(weeks, id: \.self) { week in
                    weekRow(week)
                }
            }
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// `viewModel.gridDays` is already laid out week by week -- chunked back into rows of 7 so
    /// each row can merge its own consecutive active days into one block.
    private var weeks: [[Date]] {
        stride(from: 0, to: viewModel.gridDays.count, by: 7).map {
            Array(viewModel.gridDays[$0 ..< min($0 + 7, viewModel.gridDays.count)])
        }
    }

    /// Figma `08 / Progress — Streak Calendar`: a run of consecutive active days reads as one
    /// solid capsule, not separate circles -- a single active day is just a capsule as wide as it
    /// is tall, which is a circle. Drawn as one background block per run, with the day numbers
    /// laid on top.
    private func weekRow(_ week: [Date]) -> some View {
        GeometryReader { geo in
            let cellWidth = geo.size.width / CGFloat(week.count)

            ZStack(alignment: .topLeading) {
                ForEach(activeRuns(in: week), id: \.self) { run in
                    Capsule()
                        .fill(Asset.Color.secondaryColor.color)
                        .frame(width: cellWidth * CGFloat(run.count), height: 32)
                        .offset(x: cellWidth * CGFloat(run.lowerBound))
                }

                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { day in
                        dayNumber(day)
                            .frame(width: cellWidth, height: 32)
                    }
                }
            }
        }
        .frame(height: 32)
    }

    /// Maximal ranges of consecutive active-day indices within one week row.
    private func activeRuns(in week: [Date]) -> [Range<Int>] {
        var runs: [Range<Int>] = []
        var runStart: Int?

        for (index, day) in week.enumerated() {
            if viewModel.isActive(day) {
                if runStart == nil { runStart = index }
            } else if let start = runStart {
                runs.append(start ..< index)
                runStart = nil
            }
        }
        if let start = runStart { runs.append(start ..< week.count) }
        return runs
    }

    private func dayNumber(_ day: Date) -> some View {
        let isActive = viewModel.isActive(day)
        let isInMonth = viewModel.isInDisplayedMonth(day)

        return Text(Self.dayFormatter.string(from: day))
            .font(Typography.bodySmall)
            .foregroundStyle(isActive ? Asset.Color.white.color
                             : isInMonth ? Asset.Color.textPrimary.color : Asset.Color.textTertiary.color)
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}
