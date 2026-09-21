//
//  WorkoutSettingsViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import SwiftUI

/// "Rest timer" row option. `off` renders as "Off", the rest as "30s", "60s"… Presentation-only:
/// `WorkoutSettings` (shared with the pre-workout settings sheet) stores the same choice as a
/// plain `restTimerEnabled`/`restTimerSeconds` pair, which is what this screen reads and writes.
enum RestTimerDuration: Int, CaseIterable, Identifiable {
    case off = 0
    case ten = 10
    case fifteen = 15
    case twenty = 20
    case thirty = 30
    case forty5 = 45
    case sixty = 60
    case ninety = 90

    var id: Int { rawValue }

    var title: String {
        self == .off ? "Off" : "\(rawValue)s"
    }

    /// The real intervals, without `off` -- what the in-session Workout Settings sheet lists,
    /// since it carries "off" as a separate toggle. Both screens read from this enum so their
    /// choices cannot drift apart.
    static var intervals: [RestTimerDuration] { allCases.filter { $0 != .off } }
}

/// "Countdown before workout" row option. Always a real duration -- there is no "off" state in
/// the design. Presentation-only, same reasoning as `RestTimerDuration` above.
enum WorkoutCountdown: Int, CaseIterable, Identifiable {
    case three = 3
    case five = 5
    case ten = 10
    case fifteen = 15
    case twenty = 20

    var id: Int { rawValue }

    var title: String { "\(rawValue)s" }
}

extension WorkoutSettingsView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()

        /// Shared with the pre-workout settings sheet (`Modules/Practice/Settings`) and what an
        /// actual session reads -- editing it here is no longer a separate, disconnected copy.
        @Published var settings = WorkoutSettings() {
            didSet {
                localStorageService.workoutSettings = settings
                if settings.musicVolume != oldValue.musicVolume {
                    musicPlayer.setVolume(Float(settings.musicVolume))
                }
            }
        }

        @Published var editingDuration: DurationField?
        @Published var isPickingSong = false
        @Published var tracks: [BackgroundMusic] = []
        @Published var isLoading = false

        /// Not mirrored onto `@Published` properties here: the player ticks `currentTime` at
        /// 4Hz, and re-publishing that through this view model would invalidate this screen's
        /// entire body (native ad included) on every tick. `WorkoutSettingsView` observes
        /// `BackgroundMusicPlayer.shared` directly in a small subview instead, so only that
        /// subview redraws.
        let musicPlayer = BackgroundMusicPlayer.shared
        private let backgroundMusicService = BackgroundMusicService.shared
        private var cancellables = Set<AnyCancellable>()

        enum DurationField: Identifiable {
            case restTimer
            case countdown

            var id: Int { self == .restTimer ? 0 : 1 }

            var title: String {
                self == .restTimer ? "Rest timer" : "Countdown before workout"
            }
        }

        var volumePercentText: String {
            "\(Int((settings.musicVolume * 100).rounded()))%"
        }

        /// The picker's current selection, derived from the shared model's raw fields.
        var restTimerOption: RestTimerDuration {
            guard settings.restTimerEnabled else { return .off }
            return RestTimerDuration(rawValue: settings.restTimerSeconds) ?? .off
        }

        var countdownOption: WorkoutCountdown {
            WorkoutCountdown(rawValue: settings.preWorkoutCountdownSeconds) ?? .ten
        }

        func selectRestTimer(isEnabled: Bool, seconds: Int) {
            settings.restTimerEnabled = isEnabled
            if isEnabled {
                settings.restTimerSeconds = seconds
            }
            editingDuration = nil
        }

        func selectCountdown(_ option: WorkoutCountdown) {
            settings.preWorkoutCountdownSeconds = option.rawValue
            editingDuration = nil
        }

        func load() {
            settings = localStorageService.workoutSettings
            loadBackgroundMusic()
        }

        private func loadBackgroundMusic() {
            isLoading = true
            backgroundMusicService.fetchBackgroundMusic()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                }, receiveValue: { [weak self] tracks in
                    guard let self else { return }
                    self.tracks = tracks
                    // Only fall back to the first track when the saved id isn't one of these --
                    // a valid saved selection stays picked rather than being reset on every visit.
                    if !tracks.contains(where: { $0.id == self.settings.selectedTrackId }), let firstTrack = tracks.first {
                        self.settings.selectedTrackId = firstTrack.id
                    }
                    // Matches the pre-workout settings sheet: audible as soon as it loads,
                    // rather than requiring a tap on the play button first.
                    if let currentTrack = self.currentTrack {
                        self.musicPlayer.play(currentTrack, volume: Float(self.settings.musicVolume)) { [weak self] in
                            self?.nextTrack()
                        }
                    }
                })
                .store(in: &cancellables)
        }

        var currentTrack: BackgroundMusic? {
            tracks.first { $0.id == settings.selectedTrackId } ?? tracks.first
        }

        func togglePlayback() {
            if musicPlayer.isPlaying {
                musicPlayer.pause()
            } else if let currentTrack {
                musicPlayer.play(currentTrack, volume: Float(settings.musicVolume)) { [weak self] in
                    self?.nextTrack()
                }
            }
        }

        func seek(to time: TimeInterval) {
            musicPlayer.seek(to: time)
        }

        func selectTrack(_ track: BackgroundMusic) {
            musicPlayer.stop()
            settings.selectedTrackId = track.id
            isPickingSong = false
        }

        func previousTrack() {
            guard let currentTrack, let index = tracks.firstIndex(where: { $0.id == currentTrack.id }) else { return }
            selectTrack(tracks[(index - 1 + tracks.count) % tracks.count])
        }

        func nextTrack() {
            guard let currentTrack, let index = tracks.firstIndex(where: { $0.id == currentTrack.id }) else { return }
            selectTrack(tracks[(index + 1) % tracks.count])
        }

        func back() {
            musicPlayer.stop()
            navigation.goBack()
        }
    }
}
