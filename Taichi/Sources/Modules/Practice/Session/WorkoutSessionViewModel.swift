//
//  WorkoutSessionViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension WorkoutSessionView {
    class ViewModel: BaseViewModel {
        /// Mirrors the Flow Practice screens in Figma: Get ready -> Exercise -> Rest -> ...,
        /// with pause opening its own screen of options rather than freezing in place.
        enum Phase: Equatable {
            case getReady
            case exercise
            case rest
            case completed
        }

        @Navigation var navigator
        @Injected var workoutService: WorkoutService
        @Injected var progressStore: WorkoutProgressStore
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var exercises: [WorkoutExercise] = []
        @Published var index = 0
        @Published var phase: Phase = .getReady
        @Published var remainingSeconds = 0
        /// Plain pause from the transport row: the session stays on the same screen.
        @Published var isPaused = false
        /// Raised by Back -- a confirmation before abandoning the session, not a pause control.
        @Published var showsPauseOptions = false
        @Published var isLoading = false
        @Published var errorMessage: String?

        /// Time actually spent working: paused, resting and backgrounded seconds are never added,
        /// which is what `PUT /v1/plans/{planId}/days/{dayId}/progress` asks for.
        private(set) var elapsedSeconds = 0

        private let workoutId: String
        private var timerCancellable: AnyCancellable?
        private var cancellables = Set<AnyCancellable>()
        private let musicPlayer = BackgroundMusicPlayer.shared

        init(workoutId: String) {
            self.workoutId = workoutId
        }

        // MARK: - Derived

        var currentExercise: WorkoutExercise? {
            exercises.indices.contains(index) ? exercises[index] : nil
        }

        var nextExercise: WorkoutExercise? {
            exercises.indices.contains(index + 1) ? exercises[index + 1] : nil
        }

        /// During rest the screen previews the exercise that is coming up.
        var displayedExercise: WorkoutExercise? {
            phase == .rest ? nextExercise : currentExercise
        }

        var positionLabel: String { "Exercise \(index + 1)/\(exercises.count)" }

        var nextPositionLabel: String { "Next: \(min(index + 2, exercises.count))/\(exercises.count)" }

        var timerLabel: String {
            String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        }

        var elapsedLabel: String {
            String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
        }

        /// The demo clip only runs while the exercise itself is running. During the Get ready
        /// countdown and rest intervals it holds on its first frame as a still preview, so the
        /// movement starts when the timer does rather than part-way through.
        var isClipPlaying: Bool { phase == .exercise && !isStopped }

        /// Anything that should freeze the clock: an explicit pause, or the exit confirmation.
        private var isStopped: Bool { isPaused || showsPauseOptions }

        // MARK: - Loading

        func loadIfNeeded() {
            guard exercises.isEmpty, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.workout(id: workoutId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] day in
                    guard let self else { return }
                    exercises = day.exercises
                    // Resuming picks up at the first exercise not already done.
                    index = day.exercises.firstIndex { !self.progressStore.isExerciseCompleted($0.id, in: self.workoutId) } ?? 0
                    beginGetReady()
                    progressStore.start(workoutId: workoutId)
                }
                .store(in: &cancellables)
        }

        /// Plays the track chosen in Workout Settings for the length of the session -- it loops
        /// since a single track rarely covers a full workout.
        private func startBackgroundMusic() {
            let settings = localStorageService.workoutSettings
            BackgroundMusicService.shared.fetchBackgroundMusic()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] tracks in
                    guard let self, let track = tracks.first(where: { $0.id == settings.selectedTrackId }) ?? tracks.first else { return }
                    self.musicPlayer.play(track, volume: Float(settings.musicVolume), loop: true)
                })
                .store(in: &cancellables)
        }

        // MARK: - Phases

        private func beginGetReady() {
            guard currentExercise != nil else {
                finish()
                return
            }
            phase = .getReady
            remainingSeconds = localStorageService.workoutSettings.preWorkoutCountdownSeconds
            startTimer()
        }

        private func beginExercise() {
            guard let exercise = currentExercise else {
                finish()
                return
            }
            phase = .exercise
            remainingSeconds = exercise.durationSeconds
            startTimer()
            // Covers every path back into an exercise -- off a rest interval, a skipped one, Previous,
            // or a restart -- with one call rather than repeating it at each call site. A harmless
            // no-op if music hasn't started yet or is already playing.
            musicPlayer.resume()
        }

        private func completeCurrentExercise() {
            guard let exercise = currentExercise else { return }
            progressStore.markExerciseCompleted(exercise, in: workoutId, activeDurationSeconds: elapsedSeconds)
            beginRestOrAdvance()
        }

        /// Rests before the next exercise when Workout Settings' rest timer is on and there is a
        /// next exercise to rest before -- otherwise moves straight on, same as before rest
        /// existed. `tick()`'s `.rest` case (or a skip/Next tap) is what actually advances once
        /// the rest interval is up.
        private func beginRestOrAdvance() {
            let settings = localStorageService.workoutSettings
            guard settings.restTimerEnabled, index + 1 < exercises.count else {
                advance()
                return
            }
            phase = .rest
            remainingSeconds = settings.restTimerSeconds
            startTimer()
            musicPlayer.pause()
        }

        private func advance() {
            guard index + 1 < exercises.count else {
                finish()
                return
            }
            index += 1
            beginExercise()
        }

        private func finish() {
            stopTimer()
            phase = .completed
            musicPlayer.stop()
            progressStore.markWorkoutCompleted(workoutId: workoutId, elapsedSeconds: elapsedSeconds)
        }

        // MARK: - Timer

        private func startTimer() {
            stopTimer()
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in self?.tick() }
        }

        private func stopTimer() {
            timerCancellable?.cancel()
            timerCancellable = nil
        }

        private func tick() {
            guard !isStopped else { return }
            musicPlayer.ensurePlaying()

            if phase == .exercise {
                elapsedSeconds += 1
            }

            guard remainingSeconds > 0 else { return }
            remainingSeconds -= 1

            guard remainingSeconds == 0 else { return }
            switch phase {
            case .getReady:
                // Music starts as the Get ready countdown hands off to the first exercise, not
                // underneath the countdown itself.
                startBackgroundMusic()
                beginExercise()
            case .exercise:
                completeCurrentExercise()
            case .rest:
                advance()
            case .completed:
                break
            }
        }

        // MARK: - Controls

        /// The transport row's middle button: stop and start the clock in place.
        func togglePause() {
            guard phase != .completed else { return }
            isPaused.toggle()
            isPaused ? musicPlayer.pause() : musicPlayer.resume()
        }

        /// Back asks before throwing away a session in progress.
        func requestExit() {
            guard phase != .completed else {
                exit()
                return
            }
            showsPauseOptions = true
            musicPlayer.pause()
        }

        /// "Keep exercising" -- picks the session back up exactly where it stopped.
        func resume() {
            showsPauseOptions = false
            isPaused = false
            musicPlayer.resume()
        }

        /// "Restart this exercise" -- same exercise, clock back to the top.
        func restartCurrentExercise() {
            showsPauseOptions = false
            isPaused = false
            musicPlayer.resume()
            beginExercise()
        }

        /// "Do it later" -- leaves the session; progress up to here is already saved.
        func doItLater() {
            stopTimer()
            musicPlayer.stop()
            navigator.goBack()
        }

        /// Leaving the app pauses rather than quietly accruing time the user did not exercise.
        func handleScenePhaseChange(isActive: Bool) {
            guard !isActive, phase != .completed else { return }
            isPaused = true
            musicPlayer.pause()
        }

        /// Skips the Get ready countdown, or the rest interval.
        func skip() {
            switch phase {
            case .getReady:
                startBackgroundMusic()
                beginExercise()
            case .rest:
                advance()
            default:
                break
            }
        }

        func previousExercise() {
            guard index > 0 else { return }
            isPaused = false
            index -= 1
            beginExercise()
        }

        func nextExerciseTapped() {
            guard phase != .completed else { return }
            isPaused = false
            if phase == .rest {
                advance()
            } else {
                completeCurrentExercise()
            }
        }

        func showInstructions() {
            guard let exercise = displayedExercise else { return }
            navigator.presentSheet(RootView.Coordinator.FullScreen.exerciseInstructions(
                title: exercise.name,
                imageUrl: exercise.imageUrl,
                howTo: exercise.howTo,
                commonMistakes: exercise.commonMistakes,
                breathingTips: exercise.breathingTips,
                guidance: exercise.guidance
            ))
        }

        func exit() {
            stopTimer()
            musicPlayer.stop()
            navigator.goBack()
        }
    }
}
