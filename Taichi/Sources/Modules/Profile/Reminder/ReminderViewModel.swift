//
//  ReminderViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

extension ReminderView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var reminders: [WorkoutReminder] = []
        @Published var isAddingReminder = false

        func load() {
            if !localStorageService.hasSeededReminders {
                localStorageService.hasSeededReminders = true
                reminders = WorkoutReminder.starterPack
                persist()
                return
            }
            reminders = localStorageService.workoutReminders
        }

        func toggle(_ reminder: WorkoutReminder) {
            update(reminder.id) { $0.isEnabled.toggle() }
        }

        func toggleWeekday(_ weekday: Int, on reminder: WorkoutReminder) {
            update(reminder.id) {
                if $0.weekdays.contains(weekday) {
                    // Never let a reminder end up with no day at all — it would silently stop firing.
                    guard $0.weekdays.count > 1 else { return }
                    $0.weekdays.remove(weekday)
                } else {
                    $0.weekdays.insert(weekday)
                }
            }
        }

        func toggleEveryDay(on reminder: WorkoutReminder) {
            update(reminder.id) {
                $0.weekdays = $0.isEveryDay ? [Calendar.current.component(.weekday, from: Date())] : WorkoutReminder.allWeekdays
            }
        }

        func add(hour: Int, minute: Int) {
            reminders.append(WorkoutReminder(hour: hour, minute: minute))
            persist()
        }

        func delete(_ reminder: WorkoutReminder) {
            reminders.removeAll { $0.id == reminder.id }
            persist()
        }

        func back() {
            navigation.goBack()
        }

        private func update(_ id: UUID, _ mutate: (inout WorkoutReminder) -> Void) {
            guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
            mutate(&reminders[index])
            persist()
        }

        private func persist() {
            localStorageService.workoutReminders = reminders
            let snapshot = reminders
            Task { await ReminderScheduler.reschedule(snapshot) }
        }
    }
}
