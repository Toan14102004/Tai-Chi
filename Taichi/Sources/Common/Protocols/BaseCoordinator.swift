//
//  BaseCoordinator.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/11/24.
//

import Foundation
import SwiftUI

protocol BaseAlert: Equatable {}

protocol BaseFullScreen: Hashable, Codable {}

protocol BaseNavigation: Hashable, Codable {}

struct DefaultAlert: BaseAlert {}

struct DefaultFullScreen: BaseFullScreen {}

struct DefaultNavigation: BaseNavigation {}

protocol BaseCoordinator {
    associatedtype Alert: BaseAlert = DefaultAlert
    associatedtype FullScreen: BaseFullScreen = DefaultFullScreen
    associatedtype Navigation: BaseNavigation = DefaultNavigation
}

struct DefaultCoordinator: BaseCoordinator {}
