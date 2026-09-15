//
//  WorkoutScheduleViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

enum WorkoutDayState {
    case finished
    case current
    case upcoming
}

extension WorkoutScheduleView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService
        @Injected var progressStore: WorkoutProgressStore

        @Published var coordinator = Coordinator()
        @Published var plan: WorkoutPlan?
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let programId: String
        private var cancellables = Set<AnyCancellable>()

        init(programId: String) {
            self.programId = programId

            progressStore.objectWillChange
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }

        func loadIfNeeded() {
            guard plan == nil, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.plan(id: programId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] plan in
                    self?.plan = plan
                }
                .store(in: &cancellables)
        }

        var heroImageUrl: URL? { plan?.coverImageUrl ?? plan?.days.first?.imageUrl }

        var totalDays: Int { plan?.totalDays ?? 0 }

        var completedDaysCount: Int {
            (plan?.days ?? []).filter { isDayFinished($0) }.count
        }

        var progressLabel: String { "\(completedDaysCount)/\(totalDays) Days" }

        var progressFraction: Double {
            guard totalDays > 0 else { return 0 }
            return Double(completedDaysCount) / Double(totalDays)
        }

        /// The schedule endpoint returns day summaries without exercise lists, so a day is judged
        /// finished by the workout-level flag the session player sets.
        func isDayFinished(_ day: WorkoutDay) -> Bool {
            progressStore.isWorkoutCompleted(day.id)
        }

        func state(for day: WorkoutDay) -> WorkoutDayState {
            if isDayFinished(day) { return .finished }
            if day.id == localStorageService.currentWorkoutDayId { return .current }
            return .upcoming
        }

        func phaseProgress(_ phase: WorkoutPhase) -> Double {
            guard !phase.days.isEmpty else { return 0 }
            return Double(phase.days.filter(isDayFinished).count) / Double(phase.days.count)
        }

        /// How far through one day the user got, for the inline bar the design shows on days that
        /// were started but not finished.
        func dayProgress(_ day: WorkoutDay) -> Double {
            progressStore.progressFraction(workoutId: day.id, exerciseCount: day.exerciseCount)
        }

        func openDay(_ day: WorkoutDay) {
            guard !day.isRestDay else { return }
            localStorageService.currentProgramId = programId
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: day.id))
        }

        func back() {
            navigator.goBack()
        }
    }
}
