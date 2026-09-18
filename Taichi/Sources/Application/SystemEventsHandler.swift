//
//  SystemEventsHandler.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Combine
import Foundation
import UIKit

protocol SystemEventsHandler {
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>)
    func sceneDidBecomeActive()
    func sceneWillResignActive()
    func sceneWillEnterBackground()
    func handlePushRegistration(result: Result<Data, Error>)
    @MainActor
    func appDidReceiveRemoteNotification(payload: [AnyHashable: Any]) async -> UIBackgroundFetchResult
    func applicationWillTerminate()
}

struct RealSystemEventsHandler: SystemEventsHandler {
    let container: DIContainer
    let deepLinksHandler: DeepLinksHandler
    let pushNotificationsHandler: PushNotificationsHandler
    @Injected var adsManager: AdsManager
    @Injected var localStorageService: LocalStorageService
    private let cancelBag = CancelBag()

    init(
        container: DIContainer,
        deepLinksHandler: DeepLinksHandler,
        pushNotificationsHandler: PushNotificationsHandler
    ) {
        self.container = container
        self.deepLinksHandler = deepLinksHandler
        self.pushNotificationsHandler = pushNotificationsHandler

        installKeyboardHeightObserver()
    }

    private func installKeyboardHeightObserver() {
        let appState = container.appState
        NotificationCenter.default.keyboardHeightPublisher
            .sink { [appState] height in
                appState[\.system.keyboardHeight] = height
            }
            .store(in: cancelBag)
    }

    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        handle(url: url)
    }

    private func handle(url: URL) {
        guard let deepLink = DeepLink(url: url) else { return }
        deepLinksHandler.open(deepLink: deepLink)
    }

    func sceneDidBecomeActive() {
        container.appState[\.system.isActive] = true
    }

    func sceneWillResignActive() {
        container.appState[\.system.isActive] = false
    }

    func sceneWillEnterBackground() {}

    func handlePushRegistration(result _: Result<Data, Error>) {}

    func appDidReceiveRemoteNotification(payload _: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        .noData
    }
    
    func applicationWillTerminate() {
        if !localStorageService.isFirstTimeOpenApp {
            localStorageService.isFirstTimeUsingApp = false
            print("Set isFirstTimeUsingApp to false")
        }
    }
}

// MARK: - Notifications

private extension NotificationCenter {
    var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        let willShow = publisher(for: UIApplication.keyboardWillShowNotification)
            .map(\.keyboardHeight)
        let willHide = publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return Publishers.Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue.height ?? 0
    }
}
