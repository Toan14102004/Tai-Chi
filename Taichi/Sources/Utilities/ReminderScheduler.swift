//
//  ReminderScheduler.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation
import UserNotifications

/// Mirrors the saved `[WorkoutReminder]` into `UNUserNotificationCenter`.
///
/// One reminder becomes one request per selected weekday, because a
/// `UNCalendarNotificationTrigger` can only carry a single weekday. Requests are keyed
/// `<reminder id>-<weekday>` so a rewrite can drop exactly the ones this feature owns
/// without touching notifications scheduled elsewhere in the app.
enum ReminderScheduler {
    private static let identifierPrefix = "workout-reminder"

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        default:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        }
    }

    /// Removes every request this feature owns, then re-adds the enabled reminders.
    static func reschedule(_ reminders: [WorkoutReminder]) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ours)

        guard !reminders.isEmpty else { return }
        guard await requestAuthorization() else { return }

        for reminder in reminders where reminder.isEnabled {
            for weekday in reminder.weekdays.sorted() {
                var components = DateComponents()
                components.hour = reminder.hour
                components.minute = reminder.minute
                components.weekday = weekday

                // `.localizedString` (not a plain literal) so a locally-scheduled notification
                // reflects the in-app language the user picked, which can differ from the
                // system language `NSLocalizedString` would otherwise read.
                let content = UNMutableNotificationContent()
                content.title = "Time to move".localizedString
                content.body = "Your Taichi session is waiting.".localizedString
                content.sound = .default

                let request = UNNotificationRequest(
                    identifier: "\(identifierPrefix)-\(reminder.id.uuidString)-\(weekday)",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                )
                try? await center.add(request)
            }
        }
    }
}
