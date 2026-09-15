//
//  SceneDelegate.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private static var systemEventsHandler: SystemEventsHandler?
    private var systemEventsHandler: SystemEventsHandler? { Self.systemEventsHandler }

    static func register(_ systemEventsHandler: SystemEventsHandler?) {
        Self.systemEventsHandler = systemEventsHandler
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        systemEventsHandler?.sceneOpenURLContexts(URLContexts)
    }

    func sceneDidBecomeActive(_: UIScene) {
        systemEventsHandler?.sceneDidBecomeActive()
    }

    func sceneWillResignActive(_: UIScene) {
        systemEventsHandler?.sceneWillResignActive()
    }
}
