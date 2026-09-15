//
//  ContentViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/9/25.
//

import Combine
import Foundation
import SwiftUI

extension ContentView {
    class ViewModel: BaseViewModel {
        @Injected var subscriptionManager: SubscriptionManager
        @Injected var progressService: ProgressService

        @Navigation var navigator

        @Published var coordinator = Coordinator()
        /// Backs the header's streak badge on the Progress tab -- kept here rather than read from
        /// `ProgressHomeView.ViewModel` since the header is drawn above the tab content and needs
        /// the count before that view's own `onAppear` would fire.
        @Published var progressStreakDays = 0

        private let cancelBag = CancelBag()
        private var cancellables = Set<AnyCancellable>()

        func openSettingsView() {
            navigator.push(Coordinator.Navigation.settingView)
        }

        func openLanguageView() {
            navigator.push(Coordinator.Navigation.languageView)
        }

        func showPremiumFullScreen() {
            navigator.presentCover(
                RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .home), withNavigation: true)
        }

        // MARK: - Progress streak badge

        func loadProgressStreakIfNeeded() {
            let today = Date()
            let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today

            progressService.registerDeviceIfNeeded()
                .flatMap { [progressService] _ in progressService.dailyTotals(from: weekStart, to: today) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }) { [weak self] days in
                    guard let self else { return }
                    progressStreakDays = progressService.streakDays(endingOn: today, in: days)
                }
                .store(in: &cancellables)
        }

        func openProgressStreak() {
            navigator.push(Coordinator.Navigation.progressStreak)
        }

        func showError(message: String) {
            coordinator.alert = .error(title: "Error", message: message)
        }

        func showSuccess(message: String) {
            coordinator.alert = .success(title: "Success", message: message)
        }

        func closeAlert() {
            coordinator.alert = nil
        }
    }
}
