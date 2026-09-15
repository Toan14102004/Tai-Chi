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
        @Injected var localStorageService: LocalStorageService
        @Injected var progressService: ProgressService

        @Published var coordinator = Coordinator()
        @Published var selectedDate = Date()
        /// The trailing 7 days ending on `selectedDate` -- the weekly chart's bars, and the
        /// source for `todayTotal` and `streakDays` below.
        @Published var weekDays: [ProgressDay] = []
        @Published var activities: [ProgressActivity] = []
        @Published var exercises: [ParticipatedWorkout] = []
        @Published var calorieGoal: Int
        @Published var isLoading = false
        @Published var errorMessage: String?
        @Published var showingGoalEditor = false

        private var hasLoadedOnce = false
        private var cancellables = Set<AnyCancellable>()

        init() {
            calorieGoal = LocalStorageService.shared.dailyCalorieGoal
        }

        var hasLoaded: Bool { hasLoadedOnce }

        /// `selectedDate`'s own entry in `weekDays` -- always present since the window is built to
        /// end on it.
        var todayTotal: ProgressDay? {
            weekDays.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        }

        var todayCalories: Double { todayTotal?.calories ?? 0 }

        var goalFraction: Double {
            guard calorieGoal > 0 else { return 0 }
            return min(todayCalories / Double(calorieGoal), 1)
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
            calorieGoal = localStorageService.dailyCalorieGoal
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

        // MARK: - Calorie goal

        func saveGoal(_ value: Int) {
            calorieGoal = max(1, value)
            localStorageService.dailyCalorieGoal = calorieGoal
            showingGoalEditor = false
        }

        // MARK: - Navigation

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
