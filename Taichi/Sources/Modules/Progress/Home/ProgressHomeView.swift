//
//  ProgressHomeView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct ProgressHomeView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.Spacing.m) {
                if viewModel.isLoading, !viewModel.hasLoaded {
                    ProgressHomeSkeletonView()
                } else if let errorMessage = viewModel.errorMessage, !viewModel.hasLoaded {
                    WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                } else {
                    streakCard

                    statsCard

                    PreloadedNativeAdsView(adKey: .discoverCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)

                    dailyActivitiesCard

                    weeklyChart(title: "Duration", suffix: "min") { Double($0.durationMinutes) }
                    weeklyChart(title: "Calories", suffix: "Kcal") { $0.calories }
                        .padding(.bottom, Layout.Spacing.m)
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.bottom, Layout.Spacing.xxl)
        }
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("progressHomeVC")
    }

    /// Figma `01/02 / Progress` — Frame 230: fire icon, "Your Streak" + day count, tap through to
    /// the streak calendar.
    private var streakCard: some View {
        Button(action: viewModel.openStreak) {
            HStack(spacing: Layout.Spacing.s) {
                Asset.Icon.Commo.fire.image.toIcon(Layout.Icon.xl)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Streak")
                        .font(Typography.subtitleSmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                    Text("\(viewModel.streakDays) day streak")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }
            .padding(Layout.Spacing.m)
            .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    /// Figma `01/02 / Progress` — Frame 229: today's Workouts / Kcal / Duration, divided by a
    /// vertical rule.
    private var statsCard: some View {
        HStack(spacing: 0) {
            todayStatBox(value: "\(viewModel.todayWorkoutsCount)", caption: "Workouts")
            Rectangle().fill(Asset.Color.borderPrimary.color).frame(width: 1, height: 60)
            todayStatBox(value: "\(Int(viewModel.todayKcalTotal))", caption: "Kcal")
            Rectangle().fill(Asset.Color.borderPrimary.color).frame(width: 1, height: 60)
            todayStatBox(value: viewModel.todayDurationText, caption: "Duration")
        }
        .padding(.vertical, Layout.Spacing.s)
        .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func todayStatBox(value: String, caption: String) -> some View {
        VStack(spacing: Layout.Spacing.xs) {
            Text(value)
                .font(Typography.subtitleMedium)
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text(caption)
                .font(Typography.labelMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }
        .frame(maxWidth: .infinity)
    }

    private var dailyActivitiesCard: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            dayPicker

            exercisesSection

            // Hidden while AppFlags.manualActivityLoggingEnabled is off -- see its doc comment:
            // the backend endpoints this list and its "Add Activity" entry point depend on 404.
            if AppFlags.manualActivityLoggingEnabled {
                activitiesSection

                Button("Add More Activities", action: viewModel.openAddActivity)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .padding(.vertical, Layout.Spacing.s)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.CornerRadius.medium, style: .continuous)
                            .stroke(Asset.Color.mainColor.color, lineWidth: 1)
                    )
                    .padding(.horizontal, Layout.Spacing.l)
                    .padding(.top, Layout.Spacing.m)
            }
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Day picker

    private var dayPicker: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            HStack {
                Button { viewModel.shiftWeek(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(viewModel.isToday ? "Today" : Self.headerFormatter.string(from: viewModel.selectedDate))
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                Button { viewModel.shiftWeek(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textTertiary.color)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canGoToNextWeek)
            }

            HStack(spacing: Layout.Spacing.xs) {
                ForEach(weekDates(containing: viewModel.selectedDate), id: \.self) { day in
                    dayCell(day)
                }
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: viewModel.selectedDate)
        let hasData = viewModel.hasActivity(on: day)

        return Button {
            viewModel.selectDate(day)
        } label: {
            VStack(spacing: Layout.Spacing.xs) {
                Text(Self.weekdayFormatter.string(from: day))
                    .font(Typography.captionSmall)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                Text(Self.dayNumberFormatter.string(from: day))
                    .font(Typography.labelMedium)
                    .foregroundStyle(dayNumberColor(isSelected: isSelected, hasData: hasData))
                    .frame(width: 32, height: 32)
                    .background(hasData && !isSelected ? Asset.Color.secondaryColor.color : Asset.Color.white.color,
                                in: Circle())
                    .overlay(
                        Circle().stroke(dayCellStrokeColor(isSelected: isSelected, hasData: hasData),
                                        lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func dayNumberColor(isSelected: Bool, hasData: Bool) -> Color {
        if isSelected {
            return Asset.Color.secondaryColor.color
        }
        if hasData {
            return Asset.Color.white.color
        }
        return Asset.Color.textSecondary.color
    }

    private func dayCellStrokeColor(isSelected: Bool, hasData: Bool) -> Color {
        if isSelected {
            return Asset.Color.secondaryColor.color
        }
        if hasData {
            return .clear
        }
        return Asset.Color.borderPrimary.color
    }

    private func weekDates(containing date: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            SectionHeaderRow(title: "Exercises")

            if viewModel.exercises.isEmpty {
                emptyCaption("No exercises yet")
            } else {
                VStack(spacing: Layout.Spacing.s) {
                    ForEach(Array(viewModel.exercises.enumerated()), id: \.element.id) { index, workout in
                        exerciseRow(workout)
                        if index < viewModel.exercises.count - 1 {
                            Rectangle().fill(Asset.Color.borderPrimary.color).frame(height: 1)
                        }
                    }
                }
            }
        }
    }

    private func exerciseRow(_ workout: ParticipatedWorkout) -> some View {
        Button { viewModel.openWorkout(workout) } label: {
            HStack(alignment: .top, spacing: Layout.Spacing.s) {
                RemoteImageView(url: workout.imageUrl)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(Typography.captionSmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    if let dayNumber = workout.dayNumber {
                        Text("Day \(dayNumber): \(workout.level)")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Asset.Color.textPrimary.color)
                    }

                    if workout.isCompleted {
                        completedStats(workout)
                    } else {
                        incompleteProgress(workout)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }
            .padding(.vertical, Layout.Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    private func completedStats(_ workout: ParticipatedWorkout) -> some View {
        HStack(spacing: 0) {
            statColumn(value: workout.date.map { Self.timeFormatter.string(from: $0) } ?? "--",
                       caption: workout.date.map { Self.exerciseDateFormatter.string(from: $0) } ?? "")
            statDivider
            statColumn(value: workout.durationLabel, caption: "Duration")
            statDivider
            statColumn(value: "\(Int(workout.calories))", caption: "Kcal")
        }
    }

    private func incompleteProgress(_ workout: ParticipatedWorkout) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Asset.Color.borderPrimary.color)
                    Capsule()
                        .fill(Asset.Color.secondaryColor.color)
                        .frame(width: geo.size.width * workout.progressFraction)
                }
            }
            .frame(width: 121, height: 4)

            Text("\(Int((workout.progressFraction * 100).rounded()))%")
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.secondaryColor.color)
        }
    }

    private func statColumn(value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text(caption)
                .font(Typography.captionSmall)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }
        .padding(.trailing, Layout.Spacing.s)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Asset.Color.borderPrimary.color)
            .frame(width: 1, height: 24)
            .padding(.trailing, Layout.Spacing.s)
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            SectionHeaderRow(title: "Activities")

            if viewModel.activities.isEmpty {
                emptyCaption("No Activities yet")
            } else {
                VStack(spacing: Layout.Spacing.s) {
                    ForEach(Array(viewModel.activities.enumerated()), id: \.element.id) { index, activity in
                        activityRow(activity)
                        if index < viewModel.activities.count - 1 {
                            Rectangle().fill(Asset.Color.borderPrimary.color).frame(height: 1)
                        }
                    }
                }
            }
        }
    }

    private func activityRow(_ activity: ProgressActivity) -> some View {
        Button { viewModel.openExistingActivity(activity) } label: {
            HStack(spacing: Layout.Spacing.s) {
                Image(systemName: activity.systemImageName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Asset.Color.secondaryColor.color)
                    .frame(width: 56, height: 56)
                    .background(Asset.Color.secondaryTint.color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                    Text(activity.name)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    HStack(spacing: 0) {
                        statColumn(value: "\(activity.durationMinutes) min", caption: "Durations")
                        statDivider
                        statColumn(value: "\(Int(activity.calories))", caption: "Kcal")
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }
            .padding(.vertical, Layout.Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    private func emptyCaption(_ text: String) -> some View {
        Text(text)
            .font(Typography.bodyMedium)
            .foregroundStyle(Asset.Color.textSecondary.color)
    }

    private func weeklyChart(title: String, suffix: String, value: @escaping (ProgressDay) -> Double) -> some View {
        let days = viewModel.weekDays
        let maxValue = max(days.map(value).max() ?? 0, 1)
        let total = days.map(value).reduce(0, +)

        return VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            HStack(spacing: Layout.Spacing.xs) {
                Button { viewModel.shiftWeek(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                
                Spacer()

                if let first = days.first?.date, let last = days.last?.date {
                    Text("\(Self.axisFormatter.string(from: first)) - \(Self.axisFormatter.string(from: last))")
                        .font(Typography.labelLarge)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
                
                Spacer()

                Button { viewModel.shiftWeek(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Asset.Color.textTertiary.color)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canGoToNextWeek)
            }

            HStack {
                Text("\(title) (\(suffix))")
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                Spacer()
                Text("\(Int(total.rounded())) \(suffix)")
                    .font(Typography.labelMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
            }

            HStack(alignment: .bottom, spacing: Layout.Spacing.xs) {
                ForEach(days) { day in
                    VStack(spacing: 4) {
                        // Every column keeps a full-height grey track (`Frame 121`'s bars sit on
                        // one, `#E7E7E7` ≈ `borderPrimary`); a value overlays a shorter capsule on
                        // top of it, bottom-aligned, so an empty day just shows bare track rather
                        // than a tiny nub.
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(Asset.Color.borderPrimary.color)
                                .frame(width: 9, height: 90)
                            if value(day) > 0 {
                                Capsule()
                                    .fill(Asset.Color.secondaryColor.color)
                                    .frame(width: 9, height: max(6, value(day) / maxValue * 90))
                            }
                        }
                        Text(Self.weekdayFormatter.string(from: day.date))
                            .font(Typography.captionSmall)
                            .foregroundStyle(Asset.Color.textSecondary.color)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110, alignment: .bottom)
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Formatters

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()

    private static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    private static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    private static let axisFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    private static let exerciseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
}
