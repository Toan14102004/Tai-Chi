//
//  WorkoutPhase.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutPhase: Identifiable {
    let id: String
    /// Nil for programs the API ships without phases; the schedule then lists days unsectioned.
    let number: Int?
    let name: String
    var days: [WorkoutDay]
}
