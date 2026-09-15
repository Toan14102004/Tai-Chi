//
//  DependencyInjector.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/11/24.
//

import Combine
import Foundation
import SwiftUI

struct DIContainer: EnvironmentKey {
    let appState: Store<AppState>

    static var defaultValue: Self { Self.default }

    private static let `default` = DIContainer(appState: AppState())

    init(appState: Store<AppState>) {
        self.appState = appState
    }

    init(appState: AppState) {
        let storeAppState = Store(appState)
        self.init(appState: storeAppState)
    }
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

// MARK: - Injection in the view hierarchy

extension View {
    func inject(_ container: DIContainer) -> some View {
        environment(\.injected, container)
    }
}
