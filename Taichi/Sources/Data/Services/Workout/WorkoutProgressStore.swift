//
//  WorkoutProgressStore.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//
//  Owns which exercises and workouts the user has finished.
//
//  Progress is written locally first so the UI reacts immediately and keeps working offline --
//  which matters for an app used mid-workout -- then pushed to the Tai Chi API best-effort via
//  `PUT /v1/plans/{planId}/days/{dayId}/progress`. That endpoint refuses any progress call before
//  `PUT .../start` has run once for the day, so `start(workoutId:)` fires the moment a day opens
//  and every write after it is safe to retry independently.
//

import Combine
import Foundation

final class WorkoutProgressStore: ObservableObject {
    @Injected var localStorageService: LocalStorageService
    @Injected var workoutService: WorkoutService

    private var cancellables = Set<AnyCancellable>()
    private var startedWorkoutIds = Set<String>()

    var completedWorkoutIds: Set<String> { Set(localStorageService.completedWorkoutIds) }

    /// Completion is asked per workout, never per exercise alone: the API reuses one `exerciseId`
    /// across many workouts, so finishing it in one says nothing about the others.
    func isExerciseCompleted(_ exerciseId: String, in workoutId: String) -> Bool {
        localStorageService.completedExerciseIds[workoutId]?.contains(exerciseId) ?? false
    }

    func isWorkoutCompleted(_ id: String) -> Bool {
        localStorageService.completedWorkoutIds.contains(id)
    }

    /// How far through a workout the user is, for the day-level progress bar.
    func completedCount(in exercises: [WorkoutExercise], workoutId: String) -> Int {
        let completed = Set(localStorageService.completedExerciseIds[workoutId] ?? [])
        return exercises.filter { completed.contains($0.id) }.count
    }

    func progressFraction(workoutId: String, exerciseCount: Int) -> Double {
        if isWorkoutCompleted(workoutId) { return 1 }
        guard exerciseCount > 0,
              let done = localStorageService.workoutCompletedCounts[workoutId] else { return 0 }
        return min(Double(done) / Double(exerciseCount), 1)
    }

    /// Tells the server a day is under way. Safe to call every time a day/session screen opens --
    /// `POST .../start` is itself idempotent server-side, and this also skips the call once this
    /// process has already made it for the workout.
    func start(workoutId: String) {
        guard !startedWorkoutIds.contains(workoutId) else { return }
        startedWorkoutIds.insert(workoutId)

        workoutService.startDay(workoutId: workoutId)
            .sink(receiveCompletion: { [weak self] completion in
                // A failed start is retried on the next call into this workout -- otherwise every
                // later progress write would 404 for the rest of the session.
                if case .failure = completion { self?.startedWorkoutIds.remove(workoutId) }
            }, receiveValue: {})
            .store(in: &cancellables)
    }

    func markExerciseCompleted(_ exercise: WorkoutExercise, in workoutId: String, activeDurationSeconds: Int) {
        guard !isExerciseCompleted(exercise.id, in: workoutId) else { return }
        objectWillChange.send()
        localStorageService.completedExerciseIds[workoutId, default: []].append(exercise.id)
        localStorageService.workoutCompletedCounts[workoutId, default: 0] += 1

        pushProgress(workoutId: workoutId, completedExerciseId: exercise.id, activeDurationSeconds: activeDurationSeconds)
    }

    /// Called when every exercise in a workout has been finished. Progress is recorded locally
    /// first -- the UI reacts immediately either way -- then pushed to the server best-effort. A
    /// failed push is not surfaced; the local record already stands.
    func markWorkoutCompleted(workoutId: String, elapsedSeconds: Int) {
        guard !isWorkoutCompleted(workoutId) else { return }
        objectWillChange.send()
        localStorageService.completedWorkoutIds.append(workoutId)

        pushProgress(workoutId: workoutId, completedExerciseId: nil, activeDurationSeconds: elapsedSeconds)
    }

    private func pushProgress(workoutId: String, completedExerciseId: String?, activeDurationSeconds: Int) {
        workoutService
            .saveDayProgress(workoutId: workoutId, completedExerciseId: completedExerciseId, activeDurationSeconds: activeDurationSeconds)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }

    /// Clears one workout's progress -- the "Restart" action on the Workout Day screen. Only this
    /// workout's exercises are forgotten; the same exercise stays done in any other workout that
    /// shares it.
    func reset(workoutId: String) {
        objectWillChange.send()
        localStorageService.completedExerciseIds[workoutId] = nil
        localStorageService.completedWorkoutIds.removeAll { $0 == workoutId }
        localStorageService.workoutCompletedCounts[workoutId] = nil
        startedWorkoutIds.remove(workoutId)

        workoutService.resetDayProgress(workoutId: workoutId)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}
