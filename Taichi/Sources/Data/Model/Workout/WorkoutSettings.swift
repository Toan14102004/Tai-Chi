//
//  WorkoutSettings.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutSettings: Codable, Equatable {
    /// A `BackgroundMusic.id` from `GET /background-music`. The picker falls back to the first
    /// track returned if this id is no longer in that list.
    var selectedTrackId: String = "music_1"
    var musicVolume: Double = 0.8
    var restTimerEnabled: Bool = false
    var restTimerSeconds: Int = 10
    var preWorkoutCountdownSeconds: Int = 10
}
