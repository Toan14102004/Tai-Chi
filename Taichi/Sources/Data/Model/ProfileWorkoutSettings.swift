//
//  WorkoutSettings.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation

/// "Rest timer" row on Workout Settings. `off` renders as "Off", the rest as "30s", "60s"…
enum RestTimerDuration: Int, Codable, CaseIterable, Identifiable {
    case off = 0
    case thirty = 30
    case forty5 = 45
    case sixty = 60
    case ninety = 90

    var id: Int { rawValue }

    var title: String {
        self == .off ? "Off" : "\(rawValue)s"
    }
}

/// "Countdown before workout" row. Always a real duration — there is no "off" state in the design.
enum WorkoutCountdown: Int, Codable, CaseIterable, Identifiable {
    case three = 3
    case five = 5
    case ten = 10
    case fifteen = 15
    case twenty = 20

    var id: Int { rawValue }

    var title: String { "\(rawValue)s" }
}

/// The Profile tab's own Workout Settings screen -- distinct from `Modules/Practice/Settings`'s
/// `WorkoutSettings`, which the two teams built independently with incompatible shapes for what
/// is conceptually the same setting. Named apart so both can exist until that's reconciled.
struct ProfileWorkoutSettings: Codable, Equatable {
    var songTitle: String = "Forbidden Nights"
    var isMusicPlaying: Bool = false
    /// 0...1. The design labels this as a whole percentage ("80%").
    var musicVolume: Double = 0.8
    var restTimer: RestTimerDuration = .off
    var countdown: WorkoutCountdown = .ten

    var volumePercentText: String {
        "\(Int((musicVolume * 100).rounded()))%"
    }
}
