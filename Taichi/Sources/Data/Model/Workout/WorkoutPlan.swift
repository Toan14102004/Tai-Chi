//
//  WorkoutPlan.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutPlan: Identifiable {
    /// The API's planId.
    let id: String
    let title: String
    let category: String
    let coverImageUrl: URL?
    let totalDays: Int
    let progressStatus: String
    let progressPercent: Double
    /// The day the plan wants opened next -- `nil` once the plan is finished.
    let currentDayId: String?
    var phases: [WorkoutPhase]

    var days: [WorkoutDay] { phases.flatMap(\.days) }

    var firstWorkoutDay: WorkoutDay? { days.first { !$0.isRestDay } }

    var currentDay: WorkoutDay? {
        guard let currentDayId else { return firstWorkoutDay }
        return days.first { $0.dayId == currentDayId } ?? firstWorkoutDay
    }
}
