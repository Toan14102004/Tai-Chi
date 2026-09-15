//
//  WorkoutSettingsViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import SwiftUI

extension WorkoutSettingsView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var settings = ProfileWorkoutSettings() {
            didSet {
                localStorageService.profileWorkoutSettings = settings
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

        func load() {
            settings = localStorageService.profileWorkoutSettings
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
                    if let firstTrack = tracks.first {
                        self.settings.songTitle = firstTrack.title
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
            tracks.first { $0.title == settings.songTitle }
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
            settings.songTitle = track.title
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
