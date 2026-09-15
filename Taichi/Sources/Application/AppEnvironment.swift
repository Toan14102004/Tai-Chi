//
//  AppEnvironment.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/11/24.
//

import Foundation
import UIKit

struct AppEnvironment {
    static var shared: AppEnvironment = .bootstrap()

    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let diContainer = DIContainer(appState: appState)
        let deepLinksHandler = RealDeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = RealPushNotificationsHandler(deepLinksHandler: deepLinksHandler)

        let systemEventsHandler = RealSystemEventsHandler(
            container: diContainer,
            deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler
        )

        return AppEnvironment(container: diContainer, systemEventsHandler: systemEventsHandler)
    }
}
