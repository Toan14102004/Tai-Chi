//
//  WorkoutSettingsSheetViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

enum WorkoutSettingsPanel {
    case overview
    case songList
    case restTimer
    case countdown
}

extension WorkoutSettingsSheet {
    class ViewModel: BaseViewModel {
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var panel: WorkoutSettingsPanel = .overview
        @Published var settings: WorkoutSettings {
            didSet {
                localStorageService.workoutSettings = settings
                if settings.musicVolume != oldValue.musicVolume {
                    musicPlayer.setVolume(Float(settings.musicVolume))
                }
            }
        }

        @Published var tracks: [BackgroundMusic] = []

        private let musicPlayer = BackgroundMusicPlayer.shared
        private let backgroundMusicService = BackgroundMusicService.shared
        private var cancellables = Set<AnyCancellable>()

        init() {
            settings = LocalStorageService.shared.workoutSettings
        }

        /// Fetches the real track list and starts previewing the saved selection, so this
        /// screen is actually audible rather than just a picker with no sound behind it.
        func load() {
            backgroundMusicService.fetchBackgroundMusic()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] tracks in
                    guard let self else { return }
                    self.tracks = tracks
                    guard let track = self.selectedTrack else { return }
                    self.musicPlayer.play(track, volume: Float(self.settings.musicVolume))
                })
                .store(in: &cancellables)
        }

        /// Stops the preview so it doesn't keep playing once the sheet is dismissed.
        func stopPreview() {
            musicPlayer.stop()
        }

        var selectedTrack: BackgroundMusic? {
            tracks.first { $0.id == settings.selectedTrackId } ?? tracks.first
        }

        func togglePlayback() {
            guard let track = selectedTrack else { return }
            if musicPlayer.isPlaying {
                musicPlayer.pause()
            } else {
                musicPlayer.play(track, volume: Float(settings.musicVolume))
            }
        }

        func selectTrack(_ track: BackgroundMusic) {
            settings.selectedTrackId = track.id
            musicPlayer.play(track, volume: Float(settings.musicVolume))
        }

        func previousTrack() {
            guard let selectedTrack, let index = tracks.firstIndex(where: { $0.id == selectedTrack.id }) else { return }
            selectTrack(tracks[(index - 1 + tracks.count) % tracks.count])
        }

        func nextTrack() {
            guard let selectedTrack, let index = tracks.firstIndex(where: { $0.id == selectedTrack.id }) else { return }
            selectTrack(tracks[(index + 1) % tracks.count])
        }

        func confirmTrack() {
            panel = .overview
        }

        func confirmRestTimer() {
            panel = .overview
        }

        func confirmCountdown() {
            panel = .overview
        }
    }
}
