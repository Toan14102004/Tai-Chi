//
//  DiscoverCategoryViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension DiscoverCategoryView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var paging = WorkoutListPaging()
        @Published var title: String
        @Published var isLoading = false
        @Published var errorMessage: String?

        /// The plan goal category, e.g. `BALANCE_MOBILITY` -- what `/v1/plans/category/{id}` takes.
        private let category: String
        private var cancellables = Set<AnyCancellable>()

        init(category: String, title: String) {
            self.category = category
            self.title = title
        }

        func loadIfNeeded() {
            guard !paging.hasLoaded, !isLoading else { return }
            load()
        }

        func load() {
            paging.reset()
            fetch(page: 1)
        }

        func loadMoreIfNeeded(reaching workout: WorkoutDay) {
            guard !isLoading, paging.shouldLoadMore(reaching: workout) else { return }
            fetch(page: paging.nextPage)
        }

        private func fetch(page: Int) {
            isLoading = true
            errorMessage = nil

            workoutService.categoryPage(category: category, page: page)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] page in
                    self?.paging.apply(page)
                }
                .store(in: &cancellables)
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.discoverWorkout(workoutId: workout.id))
        }

        func back() {
            navigator.goBack()
        }
    }
}
