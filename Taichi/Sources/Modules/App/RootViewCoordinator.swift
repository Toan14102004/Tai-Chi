//
//  RootViewCoordinator.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

extension RootView {
    struct Coordinator: BaseCoordinator {
        enum Navigation: BaseNavigation {
            case welcome
            case language
            case onboarding
            case profileSetup
            case content
        }

        enum FullScreen: BaseFullScreen {
            case subscription(subscriptionEntryPoint: SubscriptionView.SubscriptionEntryPoint)
            /// Shared exercise "how to do it" sheet -- any screen holding a `WorkoutExercise` can
            /// present this rather than owning its own copy of `ExerciseInstructionsView`.
            case exerciseInstructions(title: String, imageUrl: URL?, howTo: [String], commonMistakes: [String], breathingTips: [String], guidance: String)
        }
    }
}
