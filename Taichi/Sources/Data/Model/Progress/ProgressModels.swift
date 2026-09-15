//
//  ProgressModels.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation

/// One day's totals -- a bar on the weekly chart, or the ring on the day the user has selected.
struct ProgressDay: Identifiable {
    var id: Date { date }
    let date: Date
    let calories: Double
    let durationMinutes: Int
}

/// A manually logged entry, or the activity a completed workout files automatically -- the
/// "Activities" list on the Progress tab shows both the same way.
struct ProgressActivity: Identifiable {
    let id: String
    let categoryId: String
    let name: String
    let iconKey: String?
    let date: Date
    let durationSeconds: Int
    let calories: Double
    /// The category's MET, carried through so the edit screen can recompute an estimate as the
    /// user changes duration without a second network round trip.
    let met: Double

    var durationMinutes: Int { durationSeconds / 60 }
}

/// One row of the "Add Activity" list.
struct ProgressCategory: Identifiable {
    let id: String
    let name: String
    let iconKey: String?
    let met: Double
    let popular: Bool

    /// Fallback for anyone who has not entered a weight in Profile Setup, so the estimate still
    /// means something rather than blocking on a missing answer.
    static let fallbackWeightKg = 65.0

    /// Standard MET formula (kcal/min = MET x 3.5 x weight(kg) / 200), sent to the server as
    /// `caloriesMode: "custom"` -- the server's own `"estimated"` mode needs a weight on file
    /// from a completed onboarding, which an anonymous device never has. See
    /// `ProgressService.dailyTotals` for why calorie totals are read back from `/activities`
    /// rather than trusted from a stored estimate.
    func estimatedCalories(forMinutes minutes: Int, weightKg: Double) -> Double {
        met * 3.5 * weightKg / 200 * Double(minutes)
    }
}

/// A workout the user has started or finished, as the Progress tab's "Exercises" card shows it.
struct ParticipatedWorkout: Identifiable {
    let id: String
    let name: String
    let imageUrl: URL?
    let level: String
    let dayNumber: Int?
    let isCompleted: Bool
    /// 0...1. Reported by the server while in progress; assumed 1 once `isCompleted` is true even
    /// if the server's own figure is missing.
    let progressFraction: Double
    let durationSeconds: Int
    let calories: Double
    let date: Date?

    var durationLabel: String { String(format: "%02d:%02d", durationSeconds / 60, durationSeconds % 60) }
}
