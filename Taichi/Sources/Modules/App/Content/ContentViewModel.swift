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

        @Navigation var navigator

        @Published var coordinator = Coordinator()

        private let cancelBag = CancelBag()

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
