//
//  PracticeHomeViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

extension PracticeHomeView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var currentPlan: HomePlanSummary?
        @Published var dailyRoutines: [DailyRoutineSummary] = []
        @Published var justForYou: [WorkoutDay] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        private var cancellables = Set<AnyCancellable>()
        private var didLoad = false

        var hasLoaded: Bool { didLoad }

        func loadIfNeeded() {
            guard !didLoad, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.home(limit: 10)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] home in
                    guard let self else { return }
                    didLoad = true
                    currentPlan = home.currentPlan
                    dailyRoutines = home.dailyRoutines
                    justForYou = home.justForYou
                }
                .store(in: &cancellables)
        }

        func openPlan(_ plan: HomePlanSummary) {
            navigator.push(ContentView.Coordinator.Navigation.workoutSchedule(programId: plan.planId))
        }

        func openRoutine(_ routine: DailyRoutineSummary) {
            navigator.push(ContentView.Coordinator.Navigation.dailyRoutine(routineId: routine.id, title: routine.title))
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: workout.id))
        }
    }
}
