//
//  ProgressHomeViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import Foundation

extension ProgressHomeView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var progressService: ProgressService

        @Published var coordinator = Coordinator()
        @Published var selectedDate = Date()
        /// The trailing 7 days ending on `selectedDate` -- the weekly chart's bars.
        @Published var weekDays: [ProgressDay] = []
        @Published var activities: [ProgressActivity] = []
        @Published var exercises: [ParticipatedWorkout] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        /// The streak card and the Workouts/Kcal/Duration card at the top always describe the
        /// real calendar "today", independent of whatever day the picker below is browsing.
        @Published var streakDays = 0
        @Published var todayWorkoutsCount = 0
        @Published var todayKcalTotal: Double = 0
        @Published var todayDurationSeconds: Int = 0

        private var hasLoadedOnce = false
        private var cancellables = Set<AnyCancellable>()

        var hasLoaded: Bool { hasLoadedOnce }

        var todayDurationText: String {
            String(format: "%02d:%02d:%02d",
                   todayDurationSeconds / 3600,
                   (todayDurationSeconds % 3600) / 60,
                   todayDurationSeconds % 60)
        }

        var isToday: Bool { Calendar.current.isDateInToday(selectedDate) }

        /// Whether the week following `selectedDate` would run past today -- disables the
        /// day picker's and both weekly charts' forward chevron rather than letting the user
        /// navigate into a week with nothing to show.
        var canGoToNextWeek: Bool {
            guard let next = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) else { return false }
            return next <= Date()
        }

        /// Whether `date` has a logged total, for the day picker's filled-circle state --
        /// looked up in the already-loaded `weekDays` window rather than a separate request.
        func hasActivity(on date: Date) -> Bool {
            guard let day = weekDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else { return false }
            return day.calories > 0 || day.durationMinutes > 0
        }

        // MARK: - Loading

        /// Reloads on every appearance rather than gating on `hasLoaded`, unlike the rest of the
        /// app's screens: this tab needs to reflect activities added, edited or deleted on a
        /// screen pushed from here, and there is no completion callback wired back for that.
        func loadIfNeeded() {
            loadTodaySummary()
            guard !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            let calendar = Calendar.current
            let weekStart = calendar.date(byAdding: .day, value: -6, to: selectedDate) ?? selectedDate

            progressService.registerDeviceIfNeeded()
                .flatMap { [progressService] _ -> AnyPublisher<(([ProgressDay], [ProgressActivity]), [ParticipatedWorkout]), NetworkError> in
                    Publishers.Zip(
                        Publishers.Zip(
                            progressService.dailyTotals(from: weekStart, to: self.selectedDate),
                            progressService.activities(on: self.selectedDate)
                        ),
                        progressService.participatedWorkouts(on: self.selectedDate)
                    )
                    .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    hasLoadedOnce = true
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] result, exercises in
                    guard let self else { return }
                    let (days, activities) = result
                    weekDays = days
                    self.activities = activities
                    self.exercises = exercises
                }
                .store(in: &cancellables)
        }

        /// Backs the streak card and the Workouts/Kcal/Duration card -- fetched separately from
        /// `load()` since those describe real "today", not `selectedDate`.
        func loadTodaySummary() {
            let today = Date()
            let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today

            progressService.registerDeviceIfNeeded()
                .flatMap { [progressService] _ in
                    Publishers.Zip(
                        progressService.dailyTotals(from: weekStart, to: today),
                        progressService.participatedWorkouts(on: today)
                    )
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }) { [weak self] days, workouts in
                    guard let self else { return }
                    streakDays = progressService.streakDays(endingOn: today, in: days)
                    let completed = workouts.filter(\.isCompleted)
                    todayWorkoutsCount = completed.count
                    todayKcalTotal = days.first { Calendar.current.isDateInToday($0.date) }?.calories ?? 0
                    todayDurationSeconds = completed.reduce(0) { $0 + $1.durationSeconds }
                }
                .store(in: &cancellables)
        }

        // MARK: - Day picker

        func selectDate(_ date: Date) {
            guard !Calendar.current.isDate(date, inSameDayAs: selectedDate) else { return }
            selectedDate = date
            load()
        }

        /// Moves the day picker and both weekly charts a week at a time -- `weeks` is `-1` or
        /// `1`, keeping the same weekday so the picker's selection stays meaningful.
        func shiftWeek(by weeks: Int) {
            guard weeks < 0 || canGoToNextWeek else { return }
            guard let newDate = Calendar.current.date(byAdding: .day, value: weeks * 7, to: selectedDate) else { return }
            selectedDate = newDate
            load()
        }

        // MARK: - Navigation

        func openStreak() {
            navigator.push(ContentView.Coordinator.Navigation.progressStreak)
        }

        func openAddActivity() {
            navigator.push(ContentView.Coordinator.Navigation.progressActivityType)
        }

        func openExistingActivity(_ activity: ProgressActivity) {
            navigator.push(ContentView.Coordinator.Navigation.progressActivityForm(
                categoryId: activity.categoryId,
                categoryName: activity.name,
                iconKey: activity.iconKey,
                met: activity.met,
                existingActivityId: activity.id,
                initialDurationSeconds: activity.durationSeconds,
                initialCalories: activity.calories
            ))
        }

        func openWorkout(_ workout: ParticipatedWorkout) {
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: workout.id))
        }
    }
}
