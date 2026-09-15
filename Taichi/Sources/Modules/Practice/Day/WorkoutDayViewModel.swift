//
//  WorkoutDayViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

extension WorkoutDayView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService
        @Injected var progressStore: WorkoutProgressStore

        @Published var coordinator = Coordinator()
        @Published var showSettings = false
        @Published var day: WorkoutDay?
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let workoutId: String
        private var cancellables = Set<AnyCancellable>()

        init(workoutId: String) {
            self.workoutId = workoutId

            // The session player writes progress; this screen renders it, so it has to redraw when
            // the store changes rather than only when its own published properties do.
            progressStore.objectWillChange
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }

        func loadIfNeeded() {
            guard day == nil, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.workout(id: workoutId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] day in
                    guard let self else { return }
                    self.day = day
                    progressStore.start(workoutId: workoutId)
                }
                .store(in: &cancellables)
        }

        var exercises: [WorkoutExercise] { day?.exercises ?? [] }

        func isCompleted(_ exercise: WorkoutExercise) -> Bool {
            progressStore.isExerciseCompleted(exercise.id, in: workoutId)
        }

        var completedCount: Int { progressStore.completedCount(in: exercises, workoutId: workoutId) }

        var hasStarted: Bool { exercises.contains { isCompleted($0) } }

        var firstPendingExercise: WorkoutExercise? {
            exercises.first { !isCompleted($0) } ?? exercises.first
        }

        func openExercise(_ exercise: WorkoutExercise) {
            localStorageService.currentWorkoutDayId = workoutId
            navigator.push(ContentView.Coordinator.Navigation.exerciseDetail(
                workoutId: workoutId,
                exerciseId: exercise.id
            ))
        }

        func startOrContinue() {
            guard !exercises.isEmpty else { return }
            localStorageService.currentWorkoutDayId = workoutId
            navigator.push(ContentView.Coordinator.Navigation.workoutSession(workoutId: workoutId))
        }

        func restart() {
            progressStore.reset(workoutId: workoutId)
        }

        func openSettings() {
            showSettings = true
        }

        func back() {
            navigator.goBack()
        }
    }
}
