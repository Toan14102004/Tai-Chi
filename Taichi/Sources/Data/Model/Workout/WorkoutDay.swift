//
//  WorkoutDay.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutDay: Identifiable, Equatable {
    let planId: String
    let dayId: String
    let dayNumber: Int
    /// Which plan stage this day belongs to, when the plan defines stages.
    let stageCode: Int?
    let planName: String
    let title: String

    let description: String
    let level: String
    let isRestDay: Bool
    let isPremium: Bool
    let imageUrl: URL?
    /// The server's own estimate, authoritative even before the exercise list is loaded.
    let durationSeconds: Int
    let exerciseCount: Int
    let kcal: Double?
    /// Empty until `/v1/plans/{planId}/days/{dayId}` has been fetched for this day.
    var exercises: [WorkoutExercise]

    /// The API scopes a day to its plan (`PUT /v1/plans/{planId}/days/{dayId}/...`), so every
    /// screen that only ever had a single "workoutId" string now carries this pair joined --
    /// `WorkoutService.split(_:)` reverses it. Kept as a computed `id` rather than a stored
    /// property so existing `workoutId: String` navigation parameters need no signature changes.
    var id: String { Self.compositeId(planId: planId, dayId: dayId) }

    static func compositeId(planId: String, dayId: String) -> String { "\(planId)#\(dayId)" }

    var isLoaded: Bool { !exercises.isEmpty }

    var netDurationSeconds: Int {
        durationSeconds > 0 ? durationSeconds : exercises.reduce(0) { $0 + $1.durationSeconds }
    }

    var netDurationMinutes: Int { Int((Double(netDurationSeconds) / 60).rounded(.up)) }

    var displayExerciseCount: Int { isLoaded ? exercises.count : exerciseCount }

    var exerciseCountLabel: String { "\(netDurationMinutes) min · \(displayExerciseCount) exercises" }

    /// "Intermediate - 17 min" -- the caption under every Discover card, daily-routine row and
    /// "Picks for today" row. Workouts the API ships without a level fall back to the duration
    /// alone rather than a stray separator.
    var levelDurationLabel: String {
        let duration = "\(netDurationMinutes) min"
        return level.isEmpty ? duration : "\(level) - \(duration)"
    }

    static func == (lhs: WorkoutDay, rhs: WorkoutDay) -> Bool {
        lhs.id == rhs.id && lhs.exercises.count == rhs.exercises.count
    }
}
