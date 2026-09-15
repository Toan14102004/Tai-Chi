//
//  SettingViewCoordinator.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/11/24.
//

import Foundation
import SwiftUI

extension SettingView {
    struct Coordinator: BaseCoordinator {
        enum Alert: BaseAlert {
            case error(title: String, message: String)
            case success(title: String, message: String)
        }

        enum FullScreen: BaseFullScreen {
            case feedback
        }

        enum Navigation: BaseNavigation {
            case language
            case feedback
        }

        var alert: Alert?
    }
}
