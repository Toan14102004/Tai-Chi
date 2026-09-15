//
//  WelcomeViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/8/26.
//

import Foundation

extension WelcomeView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator

        @Published var coordinator = Coordinator()

        func getStarted() {
            navigator.push(RootView.Coordinator.Navigation.language)
        }
    }
}
