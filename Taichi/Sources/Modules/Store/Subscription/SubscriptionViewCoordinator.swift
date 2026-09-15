//
//  SubscriptionViewCoordinator.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/9/25.
//

import Foundation

extension SubscriptionView {
    struct Coordinator: BaseCoordinator {
        enum Alert: BaseAlert {
            case error(title: String, message: String)
            case success(title: String, message: String)
        }

        var alert: Alert?
    }
}
