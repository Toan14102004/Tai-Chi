//
//  ProfileViewCoordinator.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation

extension ProfileView {
    /// Profile is a tab, so its pushes travel on `ContentView`'s path — that is where the
    /// `flowDestination` builders live. This coordinator only carries alerts.
    struct Coordinator: BaseCoordinator {}
}
