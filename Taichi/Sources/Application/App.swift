//
//  App.swift
//  Taichi
//
//  Created by Toan Nguyen on 11/2/25.
//

import Foundation
import SwiftUI

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Injected var loadingService: LoadingService
    
    var body: some Scene {
        WindowGroup {
            appDelegate.rootView
                .environmentObject(loadingService)
        }
    }
}

extension AppEnvironment {
    var rootView: some View {
        RootView(viewModel: .init(container: container))
            .modifier(RootViewAppearance())
            .inject(container)
            .colorScheme(.dark)
    }
}
