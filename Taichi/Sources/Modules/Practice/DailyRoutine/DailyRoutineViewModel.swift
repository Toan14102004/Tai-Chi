//
//  DailyRoutineViewModel.swift
//  Taichi
//

import Combine
import Foundation

extension DailyRoutineView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var title: String
        /// Cover photo behind the header; nil until the detail call lands.
        @Published var imageUrl: URL?
        @Published var sessionCount = 0
        @Published var items: [WorkoutDay] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let routineId: String
        private var cancellables = Set<AnyCancellable>()
        private var didLoad = false

        var hasLoaded: Bool { didLoad }

        init(routineId: String, title: String) {
            self.routineId = routineId
            self.title = title
        }

        func loadIfNeeded() {
            guard !hasLoaded, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.dailyRoutine(id: routineId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] result in
                    guard let self else { return }
                    didLoad = true
                    if !result.title.isEmpty { title = result.title }
                    imageUrl = result.imageUrl
                    sessionCount = result.sessionCount
                    items = result.items
                }
                .store(in: &cancellables)
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: workout.id))
        }

        func back() {
            navigator.goBack()
        }
    }
}
