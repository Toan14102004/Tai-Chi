//
//  ContentViewCoordinator.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/9/25.
//

import Foundation
import SwiftUI

extension ContentView {
  struct Coordinator: BaseCoordinator {
    enum Alert: BaseAlert {
      case error(title: String, message: String)
      case success(title: String, message: String)
    }

    enum Navigation: BaseNavigation {
      case settingView
      case languageView
case workoutSchedule(programId: String)
      case workoutDay(workoutId: String)
      case exerciseDetail(workoutId: String, exerciseId: String)
      case workoutSession(workoutId: String)
      case dailyRoutine(routineId: String, title: String)
      case discoverCategory(category: String, title: String)
      case discoverWorkout(workoutId: String)
      case progressActivityType
      /// Add a new activity for `category`, or edit `existingActivityId` if it came from tapping
      /// an already-logged entry. Carrying name/icon/MET here (rather than just an id) lets the
      /// form recompute its calorie estimate as duration changes without a second network call.
      case progressActivityForm(
        categoryId: String,
        categoryName: String,
        iconKey: String?,
        met: Double,
        existingActivityId: String?,
        initialDurationSeconds: Int,
        initialCalories: Double
      )
      case progressStreak
        case personalDetails
      case workoutSettings
      case reminder
    }

    var alert: Alert?
  }
}
