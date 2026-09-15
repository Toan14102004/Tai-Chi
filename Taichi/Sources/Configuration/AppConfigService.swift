//
//  AppConfigService.swift
//  Taichi
//
//  Created by Toan Nguyen on 22/8/26.
//

import Foundation

/// Signals that startup configuration is ready. This used to wait on a Firebase Remote Config
/// fetch; there is no remote config source anymore, so it fires immediately on launch.
/// `SplashView`, `SubscriptionManager`, and `AdsPreloadService` all observe `.appConfigReady`
/// and proceed using the local defaults already defined in `LocalStorageService`/`KeychainStorageService`.
class AppConfigService: Service {
    var shouldAutostart: Bool = true

    func start() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .appConfigReady, object: nil)
        }
    }

    func stop() {}
}
