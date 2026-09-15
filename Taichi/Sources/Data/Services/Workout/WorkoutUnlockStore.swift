//
//  WorkoutUnlockStore.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

/// Owns which Discover workouts the user may open.
///
/// Per the Discover design note, every workout in the feed starts locked: the exercise list is
/// hidden until the user either watches a rewarded ad or subscribes. Subscribers are never
/// checked against the stored list -- they unlock everything, including workouts they unlock
/// after cancelling, which then fall back to whatever they paid an ad for.
///
/// Like `WorkoutProgressStore`, values are read through to `LocalStorageService` on every access
/// rather than cached in `@Published` properties: this type is built by `Dependencies.build()`,
/// and resolving another dependency from `init` runs before the container is ready and traps.
///
/// Main-actor isolated because `SubscriptionManager` is: the lock state is a question about the
/// subscription, and every caller is a view or a view model that already runs there.
@MainActor
final class WorkoutUnlockStore: ObservableObject {
    @Injected var localStorageService: LocalStorageService
    @Injected var subscriptionManager: SubscriptionManager

    var isSubscribed: Bool { subscriptionManager.isSubscribed }

    func isUnlocked(_ workoutId: String) -> Bool {
        if isSubscribed { return true }
        return localStorageService.unlockedWorkoutIds.contains(workoutId)
    }

    func unlock(_ workoutId: String) {
        guard !localStorageService.unlockedWorkoutIds.contains(workoutId) else { return }
        objectWillChange.send()
        localStorageService.unlockedWorkoutIds.append(workoutId)
    }
}
