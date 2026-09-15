//
//  ProgressActivityTypeViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import Foundation

extension ProgressActivityTypeView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var progressService: ProgressService

        @Published var coordinator = Coordinator()
        @Published var categories: [ProgressCategory] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        private var cancellables = Set<AnyCancellable>()

        func loadIfNeeded() {
            guard categories.isEmpty, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            progressService.categories()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] categories in
                    self?.categories = categories
                }
                .store(in: &cancellables)
        }

        func back() {
            navigator.goBack()
        }

        func open(_ category: ProgressCategory) {
            navigator.push(ContentView.Coordinator.Navigation.progressActivityForm(
                categoryId: category.id,
                categoryName: category.name,
                iconKey: category.iconKey,
                met: category.met,
                existingActivityId: nil,
                initialDurationSeconds: 0,
                initialCalories: 0
            ))
        }
    }
}
