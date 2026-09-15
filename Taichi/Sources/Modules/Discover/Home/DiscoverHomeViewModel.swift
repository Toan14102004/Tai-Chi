//
//  DiscoverHomeViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension DiscoverHomeView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService
        @Injected var progressStore: WorkoutProgressStore

        @Published var coordinator = Coordinator()
        @Published var sections: [DiscoverSection] = []
        /// Recently practised workouts, for the untitled photo carousel under the first ad.
        @Published var recentWorkouts: [WorkoutDay] = []
        /// The plan the user has under way, for the "Recent" card. Nil until one is started.
        @Published var recentPlan: WorkoutPlan?
        @Published var isLoading = false
        @Published var errorMessage: String?

        private var cancellables = Set<AnyCancellable>()

        var hasLoaded: Bool { !sections.isEmpty }

        func loadIfNeeded() {
            // The Recent card tracks progress written by the session player, so it is refreshed on
            // every appearance even when the feed itself is already in hand.
            loadRecentPlan()
            guard !hasLoaded, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.discoverContent(sectionLimit: 6)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] content in
                    self?.recentWorkouts = content.recent
                    self?.sections = content.sections.filter { !$0.items.isEmpty }
                }
                .store(in: &cancellables)
        }

        /// Loaded on its own rather than zipped with the feed: a plan that fails to load should
        /// cost the user the Recent card, not the whole of Discover.
        private func loadRecentPlan() {
            guard let programId = localStorageService.currentProgramId else {
                recentPlan = nil
                return
            }
            guard recentPlan?.id != programId else { return }

            workoutService.plan(id: programId)
                .receive(on: DispatchQueue.main)
                .sink { _ in } receiveValue: { [weak self] plan in
                    self?.recentPlan = plan
                }
                .store(in: &cancellables)
        }

        // MARK: - Recent

        /// The day the user is on, falling back to the first day they have not finished.
        var recentDay: WorkoutDay? {
            guard let plan = recentPlan else { return nil }
            if let dayId = localStorageService.currentWorkoutDayId,
               let day = plan.days.first(where: { $0.id == dayId })
            {
                return day
            }
            return plan.days.first { !$0.isRestDay && !progressStore.isWorkoutCompleted($0.id) }
        }

        var recentSubtitle: String {
            guard let day = recentDay, day.dayNumber > 0 else { return "" }
            return "Day \(day.dayNumber)"
        }

        var recentProgress: Double {
            guard let plan = recentPlan else { return 0 }
            return plan.progressPercent / 100
        }

        // MARK: - Navigation

        func openRecentPlan() {
            guard let plan = recentPlan else { return }
            navigator.push(ContentView.Coordinator.Navigation.workoutSchedule(programId: plan.id))
        }

        func openSection(_ section: DiscoverSection) {
            navigator.push(ContentView.Coordinator.Navigation.discoverCategory(
                category: section.id,
                title: section.title
            ))
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.discoverWorkout(workoutId: workout.id))
        }
    }
}
