//
//  ProfileViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import SwiftUI

extension ProfileView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService
        @Injected var progressService: ProgressService

        @Published var coordinator = Coordinator()
        @Published var profile = UserProfile()
        /// Backs the header's streak pill -- computed the same way as the Progress tab's, so the
        /// two stay consistent instead of this one reading the always-zero `profile.streakCount`.
        @Published var streakDays = 0

        private var cancellables = Set<AnyCancellable>()

        /// Re-read on every appearance: Personal Details writes straight to storage,
        /// so popping back has to pick the new name / avatar up.
        func reload() {
            profile = localStorageService.userProfile
            loadStreak()
        }

        private func loadStreak() {
            let today = Date()
            let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today

            progressService.registerDeviceIfNeeded()
                .flatMap { [progressService] _ in progressService.dailyTotals(from: weekStart, to: today) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }) { [weak self] days in
                    guard let self else { return }
                    streakDays = progressService.streakDays(endingOn: today, in: days)
                }
                .store(in: &cancellables)
        }

        var avatarImage: UIImage? {
            profile.avatarImageData.flatMap(UIImage.init(data:))
        }

        // MARK: - Navigation

        func openStreak() {
            navigation.push(ContentView.Coordinator.Navigation.progressStreak)
        }

        func openPersonalDetails() {
            navigation.push(ContentView.Coordinator.Navigation.personalDetails)
        }

        func openWorkoutSettings() {
            navigation.push(ContentView.Coordinator.Navigation.workoutSettings)
        }

        func openReminder() {
            navigation.push(ContentView.Coordinator.Navigation.reminder)
        }

        func openLanguage() {
            navigation.push(ContentView.Coordinator.Navigation.languageView)
        }

        func openPremium() {
            navigation.presentCover(
                RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .settings),
                withNavigation: true
            )
        }

        // MARK: - Links

        func rateUs() {
            let urlString = "https://apps.apple.com/app/id\(AppConfiguration.appId)?action=write-review"
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }

        func shareApp() {
            openShareView(["https://apps.apple.com/app/\(AppConfiguration.appId)"])
        }

        func openTermOfUse() {
            guard let url = URL(string: AppConfiguration.termOfUseUrl) else { return }
            UIApplication.shared.open(url)
        }

        func openPrivacyPolicy() {
            guard let url = URL(string: AppConfiguration.privacyUrl) else { return }
            UIApplication.shared.open(url)
        }
    }
}
