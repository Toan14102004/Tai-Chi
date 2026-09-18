//
//  WorkoutSettingsSheet.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct WorkoutSettingsSheet: View {
    @ObservedObject var viewModel: ViewModel
    /// Observed directly (rather than proxied through the view model) so the play/pause icon
    /// updates live as this shared player's state changes.
    @ObservedObject private var musicPlayer = BackgroundMusicPlayer.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            header

            switch viewModel.panel {
            case .overview: overviewPanel
            case .songList: songListPanel
            case .restTimer: restTimerPanel
            case .countdown: countdownPanel
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Asset.Color.white.color.ignoresSafeArea())
        .onAppear(perform: viewModel.load)
        .onDisappear(perform: viewModel.stopPreview)
    }

    // MARK: - Header

    /// Figma draws the overview and song-list sheets with a close X and no back arrow, and the
    /// rest-timer/countdown sheets with neither. That reads as separate screens reached by
    /// pushing, which this single sheet approximates with a panel switch instead -- so a back
    /// chevron is kept on every non-root panel for the affordance the design assumes exists.
    private var header: some View {
        HStack(alignment: .top, spacing: Layout.Spacing.s) {
            if viewModel.panel != .overview {
                Button {
                    viewModel.panel = .overview
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 24, height: 24)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(headerTitle)
                    .font(Typography.subtitleLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                if viewModel.panel == .restTimer {
                    Text("Set the reset time between exercise")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }

            Spacer(minLength: Layout.Spacing.s)

            if viewModel.panel == .restTimer {
                Toggle("", isOn: $viewModel.settings.restTimerEnabled)
                    .labelsHidden()
                    .tint(Asset.Color.mainColor.color)
            } else if viewModel.panel != .countdown {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }

    private var headerTitle: String {
        switch viewModel.panel {
        case .overview: "Workout Setting"
        case .songList: "Song List"
        case .restTimer: "Rest timer"
        case .countdown: "Countdown before workout"
        }
    }

    // MARK: - Overview

    private var overviewPanel: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("Music")

                VStack(spacing: 12) {
                    musicCard
                    volumeCard
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("Duration")

                VStack(spacing: 12) {
                    settingsRow(
                        title: "Rest timer",
                        value: viewModel.settings.restTimerEnabled ? "\(viewModel.settings.restTimerSeconds)s" : "Off",
                        action: { viewModel.panel = .restTimer }
                    )
                    settingsRow(
                        title: "Countdown before workout",
                        value: "\(viewModel.settings.preWorkoutCountdownSeconds)s",
                        action: { viewModel.panel = .countdown }
                    )
                }
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(Typography.bodyLarge)
            .foregroundStyle(Asset.Color.textSecondary.color)
    }

    /// The bouncing bars while music is actually playing, the same static icon Profile's
    /// Workout Settings uses the rest of the time.
    @ViewBuilder
    private var soundWaveIcon: some View {
        if musicPlayer.isPlaying {
            SoundWaveAnimation()
                .frame(width: 24, height: 24)
        } else {
            Asset.Icon.Profile.soundWave.image
                .resizable()
                .frame(width: 24, height: 24)
        }
    }

    private var musicCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: Layout.Spacing.s) {
                soundWaveIcon

                Text(viewModel.selectedTrack?.title ?? "Loading…")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .lineLimit(1)

                Spacer(minLength: Layout.Spacing.s)

                HStack(spacing: 12) {
                    trackButton(systemImage: "chevron.left", background: .white, action: viewModel.previousTrack)
                    Button(action: viewModel.togglePlayback) {
                        Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Asset.Color.textPrimary.color)
                            .frame(width: 24, height: 24)
                    }
                    trackButton(systemImage: "chevron.right", background: .white, action: viewModel.nextTrack)
                }
            }

            Button("See All Songs") { viewModel.panel = .songList }
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.mainColor.color)
        }
        .padding(12)
        .background(Color(hex: "#F2F2F2"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func trackButton(systemImage: String, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Asset.Color.textPrimary.color)
                .frame(width: 20, height: 20)
                .background(background)
                .clipShape(Circle())
        }
    }

    private var volumeCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Music Volume")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                Spacer()
                Text("\(Int(viewModel.settings.musicVolume * 100))%")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }

            HStack(spacing: 16) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Asset.Color.textPrimary.color)
                Slider(value: $viewModel.settings.musicVolume, in: 0...1)
                    .tint(Asset.Color.mainColor.color)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Asset.Color.textPrimary.color)
            }
        }
        .padding(12)
        .background(Color(hex: "#F2F2F2"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func settingsRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                Spacer()
                Text(value)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.s)
            .frame(height: 56)
            .background(Color(hex: "#F2F2F2"))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Song list

    private var songListPanel: some View {
        VStack(spacing: Layout.Spacing.m) {
            VStack(spacing: 8) {
                ForEach(viewModel.tracks) { track in
                    songRow(track)
                }
            }

            primaryButton("Save", action: viewModel.confirmTrack)
        }
    }

    private func songRow(_ track: BackgroundMusic) -> some View {
        let isSelected = track.id == viewModel.settings.selectedTrackId

        return Button {
            viewModel.selectTrack(track)
        } label: {
            HStack(spacing: Layout.Spacing.s) {
                if isSelected {
                    soundWaveIcon
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(isSelected ? Asset.Color.mainColor.color : Asset.Color.textPrimary.color)
                    Text(track.durationLabel)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Asset.Color.mainColor.color)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Asset.Color.mainColor.color : Asset.Color.borderPrimary.color, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rest timer

    private var restTimerPanel: some View {
        VStack(spacing: Layout.Spacing.m) {
            VStack(spacing: Layout.Spacing.s) {
                ForEach([10, 15], id: \.self) { seconds in
                    optionPill(title: "\(seconds)s", isSelected: viewModel.settings.restTimerSeconds == seconds) {
                        viewModel.settings.restTimerSeconds = seconds
                    }
                }
            }
            .opacity(viewModel.settings.restTimerEnabled ? 1 : 0.4)
            .disabled(!viewModel.settings.restTimerEnabled)

            primaryButton("Done", action: viewModel.confirmRestTimer)
        }
    }

    // MARK: - Countdown

    private var countdownPanel: some View {
        VStack(spacing: Layout.Spacing.m) {
            VStack(spacing: Layout.Spacing.s) {
                ForEach([5, 10, 15], id: \.self) { seconds in
                    optionPill(title: "\(seconds)s", isSelected: viewModel.settings.preWorkoutCountdownSeconds == seconds) {
                        viewModel.settings.preWorkoutCountdownSeconds = seconds
                    }
                }
            }

            primaryButton("Done", action: viewModel.confirmCountdown)
        }
    }

    // MARK: - Shared pieces

    /// Selection here reads as a tint change on a light card, not an inverted filled button --
    /// matching Figma's rest-timer and countdown pills (`2052:2155`, `2052:2659`).
    private func optionPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headlineSmall)
                .foregroundStyle(isSelected ? Asset.Color.mainColor.color : Asset.Color.textTertiary.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color(hex: "#F2F2F2") : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Asset.Color.mainColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
