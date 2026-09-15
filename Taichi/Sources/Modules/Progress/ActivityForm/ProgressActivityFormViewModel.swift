//
//  ProgressActivityFormViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import Foundation

extension ProgressActivityFormView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var progressService: ProgressService

        @Published var coordinator = Coordinator()
        @Published var minutes: Int
        @Published var isSaving = false
        @Published var errorMessage: String?

        let categoryName: String
        private let categoryId: String
        private let met: Double
        private let existingActivityId: String?
        private var cancellables = Set<AnyCancellable>()

        var isEditing: Bool { existingActivityId != nil }

        init(categoryId: String,
            categoryName: String,
            met: Double,
            existingActivityId: String?,
            initialDurationSeconds: Int)
        {
            self.categoryId = categoryId
            self.categoryName = categoryName
            self.met = met
            self.existingActivityId = existingActivityId
            minutes = initialDurationSeconds / 60
        }

        /// The server's own `caloriesMode: "estimated"` needs a weight on file from a completed
        /// onboarding, which an anonymous device never has -- see `ProgressCategory
        /// .estimatedCalories`. `currentWeightKg` is what Profile Setup already collects locally;
        /// falls back to a nominal weight for anyone who has not answered that step yet.
        var estimatedCalories: Double {
            let weightKg = localStorageService.profileSetupAnswers.currentWeightKg ?? ProgressCategory.fallbackWeightKg
            let category = ProgressCategory(id: categoryId, name: categoryName, iconKey: nil, met: met, popular: false)
            return category.estimatedCalories(forMinutes: minutes, weightKg: weightKg)
        }

        var canSave: Bool { minutes > 0 && !isSaving }

        func close() {
            navigator.goBack()
        }

        // `ProgressHomeView` reloads unconditionally on every appearance (see its own doc
        // comment), so popping back after a successful save or delete is enough to refresh it --
        // no completion callback needed here.
        func save() {
            guard canSave else { return }
            isSaving = true
            errorMessage = nil

            let durationSeconds = minutes * 60
            let calories = estimatedCalories

            let publisher: AnyPublisher<Void, NetworkError>
            if let existingActivityId {
                publisher = progressService.updateActivity(id: existingActivityId, durationSeconds: durationSeconds, calories: calories)
            } else {
                let category = ProgressCategory(id: categoryId, name: categoryName, iconKey: nil, met: met, popular: false)
                publisher = progressService.registerDeviceIfNeeded()
                    .flatMap { [progressService] in
                        progressService.createActivity(category: category, activityAt: Date(), durationSeconds: durationSeconds, calories: calories)
                    }
                    .eraseToAnyPublisher()
            }

            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isSaving = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] in
                    self?.navigator.goBack()
                }
                .store(in: &cancellables)
        }

        func delete() {
            guard let existingActivityId else { return }
            isSaving = true
            errorMessage = nil

            progressService.deleteActivity(id: existingActivityId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isSaving = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] in
                    self?.navigator.goBack()
                }
                .store(in: &cancellables)
        }
    }
}
