//
//  WorkoutExercise.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutExercise: Identifiable, Equatable {
    let id: String
    let order: Int
    let name: String
    /// Still photo for list rows. The API often has no per-exercise photo and falls back to the
    /// parent workout's cover, so this can be nil and callers should substitute the workout image.
    let imageUrl: URL?
    /// Demo clip (MP4). Present for essentially every exercise the API serves.
    let videoUrl: URL?
    var durationSeconds: Int
    let howTo: [String]
    let commonMistakes: [String]
    let breathingTips: [String]
    /// The single free-text paragraph the API sends alongside the step list.
    let guidance: String

    var durationLabel: String {
        String(format: "%02d:%02d", durationSeconds / 60, durationSeconds % 60)
    }

    var hasInstructions: Bool {
        !howTo.isEmpty || !commonMistakes.isEmpty || !breathingTips.isEmpty || !guidance.isEmpty
    }

    static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        lhs.id == rhs.id && lhs.durationSeconds == rhs.durationSeconds
    }
}
