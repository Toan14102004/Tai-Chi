//
//  WorkoutReminder.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation

/// One scheduled nudge to work out. Days follow `Calendar` weekday numbering (1 = Sunday)
/// so they can be handed straight to `UNCalendarNotificationTrigger`.
struct WorkoutReminder: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var hour: Int
    var minute: Int
    var weekdays: Set<Int> = Set(1...7)
    var isEnabled: Bool = true

    static let allWeekdays = Set(1...7)

    /// "17:00" — 24-hour, zero padded, matching the design.
    var timeText: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var isEveryDay: Bool {
        weekdays == Self.allWeekdays
    }

    /// What a fresh install starts with, mirroring the two cards in the design so the screen
    /// is never empty on first open. Seeded once — deleting them is permanent.
    static let starterPack: [WorkoutReminder] = [
        WorkoutReminder(hour: 17, minute: 0),
        WorkoutReminder(hour: 5, minute: 0),
    ]

    /// Two-letter labels in the order the design lays them out, starting on Sunday.
    static let weekdaySymbols: [(weekday: Int, label: String)] = [
        (1, "Su"), (2, "Mo"), (3, "Tu"), (4, "We"), (5, "Th"), (6, "Fr"), (7, "Sa"),
    ]
}
