//
//  WorkoutSettingsView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// The song card and scrub bar, split out of `WorkoutSettingsView` so they can observe
/// `BackgroundMusicPlayer` directly. The player ticks `currentTime` at 4Hz; publishing that
/// through the screen's own view model would invalidate the whole screen's body -- native ad
/// included -- on every tick instead of just this section.
private struct MusicPlayerSection: View {
    @ObservedObject var viewModel: WorkoutSettingsView.ViewModel
    @ObservedObject private var musicPlayer = BackgroundMusicPlayer.shared

    var body: some View {
        VStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
            musicCard
            playbackBar
        }
    }

    private var musicCard: some View {
        HStack(spacing: Layout.Spacing.m) {
            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                HStack(spacing: Layout.Spacing.xs) {
                    if musicPlayer.isPlaying {
                        SoundWaveAnimation()
                            .frame(width: 24, height: 24)
                            .accessibilityLabel("Music playing")
                    } else {
                        Asset.Icon.Profile.soundWave.image
                            .resizable()
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)
                    }

                    Text(viewModel.currentTrack?.title ?? "Loading…")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)
                }

                Button {
                    viewModel.isPickingSong = true
                } label: {
                    Text("See All Songs")
                        .font(FontFamily.Inter.medium.font(size: 12))
                        .foregroundStyle(Asset.Color.mainColor.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                Button(action: viewModel.previousTrack) {
                    // Mirrored `chevronRight` rather than `backChevron`: the two came from
                    // different icon sets and did not match as a Prev/Next pair.
                    controlButton(Asset.Icon.Profile.chevronRight.image, size: 20)
                        .scaleEffect(x: -1, y: 1)
                }

                Button(action: viewModel.togglePlayback) {
                    Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 26, height: 26)
                        .background(Asset.Color.white.color)
                        .clipShape(Circle())
                }

                Button(action: viewModel.nextTrack) {
                    controlButton(Asset.Icon.Profile.chevronRight.image, size: 20)
                }
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
        .frame(height: 72)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private var playbackBar: some View {
        VStack(spacing: Layout.Spacing.m) {
            Slider(value: Binding(get: { musicPlayer.currentTime }, set: { viewModel.seek(to: $0) }),
                   in: 0...max(musicPlayer.duration, 1))
                .tint(Asset.Color.mainColor.color)

            HStack {
                Text(formatTime(musicPlayer.currentTime))
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                Spacer()

                Text(formatTime(musicPlayer.duration))
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.textSecondary.color)
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private func controlButton(_ image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .frame(width: size, height: size)
            .frame(width: 26, height: 26)
            .background(Asset.Color.white.color)
            .clipShape(Circle())
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct WorkoutSettingsView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavBar(title: "profile.row.workout_settings".localizedString, onBack: viewModel.back)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Layout.Spacing.m) {
                    section("Music") {
                        MusicPlayerSection(viewModel: viewModel)
                        volumeCard
                    }

                    section("Duration") {
                        durationRow(title: "Rest timer", value: viewModel.restTimerOption.title) {
                            viewModel.editingDuration = .restTimer
                        }
                        durationRow(title: "Countdown before workout", value: viewModel.countdownOption.title) {
                            viewModel.editingDuration = .countdown
                        }
                    }

                    PreloadedNativeAdsView(adKey: .profileMedium, style: .contentCard, height: NativeAdViewStyle.contentCard.height)
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: viewModel.load)
        .sheet(item: $viewModel.editingDuration) { field in
            durationPicker(for: field)
        }
        .sheet(isPresented: $viewModel.isPickingSong) {
            songPicker
                .presentationDetents([.medium])
        }
        .trackScreen("workoutSettingsVC")
    }

    // MARK: - Sections

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s + Layout.Spacing.xs) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textSecondary.color)

            VStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var volumeCard: some View {
        VStack(spacing: Layout.Spacing.l) {
            HStack {
                Text("Music Volume")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                Text(viewModel.volumePercentText)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }

            HStack(spacing: Layout.Spacing.m) {
                Asset.Icon.Profile.volumeMin.image
                    .resizable()
                    .frame(width: 24, height: 24)

                Slider(value: $viewModel.settings.musicVolume, in: 0...1)
                    .tint(Asset.Color.mainColor.color)

                Asset.Icon.Profile.volumeMax.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private func durationRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer(minLength: Layout.Spacing.m)

                Text(value)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                Asset.Icon.Profile.chevronRight.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, Layout.Spacing.s + Layout.Spacing.xs)
            .frame(height: 56)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// Bottom sheets from Figma "Workout Settings -- Rest Timer On/Off" and "Pre-Workout
    /// Countdown". Rest timer carries its on/off switch in the header (as in the design) rather
    /// than an "Off" stop in the wheel, and its wheel lists the same intervals as the in-session
    /// sheet.
    @ViewBuilder
    private func durationPicker(for field: ViewModel.DurationField) -> some View {
        switch field {
        case .restTimer:
            let intervals = RestTimerDuration.intervals.map(\.rawValue)
            DurationWheelSheet(
                title: field.title,
                subtitle: "Set the reset time between exercise",
                values: intervals,
                initial: intervals.contains(viewModel.settings.restTimerSeconds)
                    ? viewModel.settings.restTimerSeconds
                    : RestTimerDuration.ten.rawValue,
                hasSwitch: true,
                initiallyEnabled: viewModel.settings.restTimerEnabled,
                onDone: { isEnabled, seconds in viewModel.selectRestTimer(isEnabled: isEnabled, seconds: seconds) }
            )
        case .countdown:
            DurationWheelSheet(
                title: field.title,
                subtitle: nil,
                values: WorkoutCountdown.allCases.map(\.rawValue),
                initial: viewModel.countdownOption.rawValue,
                hasSwitch: false,
                initiallyEnabled: true,
                onDone: { _, seconds in viewModel.selectCountdown(WorkoutCountdown(rawValue: seconds) ?? .ten) }
            )
        }
    }

    private var songPicker: some View {
        NavigationView {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.tracks) { track in
                    Button {
                        viewModel.selectTrack(track)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title)
                                    .foregroundStyle(Asset.Color.textPrimary.color)
                                Text(track.author)
                                    .font(Typography.bodySmall)
                                    .foregroundStyle(Asset.Color.textSecondary.color)
                                Text(track.durationFormatted)
                                    .font(Typography.captionSmall)
                                    .foregroundStyle(Asset.Color.textTertiary.color)
                            }
                            Spacer()
                            if track.id == viewModel.settings.selectedTrackId {
                                Asset.Icon.Profile.tickCircle.image
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
                .navigationTitle("Songs")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .colorScheme(.light)
    }
}

/// Bottom sheet with a title, an optional on/off switch, a three-row wheel and a Done button.
/// Holds the pending choice locally so scrolling does not write to the shared settings (and
/// dismiss the sheet) until the user confirms.
///
/// Sized to the design: 32pt top/bottom padding, 32pt between blocks, 52pt wheel rows inset 16pt
/// (Figma frames 09-11 -- Rest timer On 394 with a full three-row wheel, Off 190, Countdown 374).
private struct DurationWheelSheet: View {
    let title: String
    let subtitle: String?
    let values: [Int]
    let hasSwitch: Bool
    let onDone: (_ isEnabled: Bool, _ value: Int) -> Void

    @State private var selection: Int
    @State private var isEnabled: Bool

    private static let rowHeight: CGFloat = 52
    private static let blockSpacing: CGFloat = 32
    private static let verticalPadding: CGFloat = 32
    private static let buttonHeight: CGFloat = 46
    private static let wheelTopInset: CGFloat = 16

    init(title: String, subtitle: String?, values: [Int], initial: Int, hasSwitch: Bool, initiallyEnabled: Bool,
         onDone: @escaping (_ isEnabled: Bool, _ value: Int) -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.values = values
        self.hasSwitch = hasSwitch
        self.onDone = onDone
        _selection = State(initialValue: initial)
        _isEnabled = State(initialValue: initiallyEnabled)
    }

    /// Whether the wheel is shown -- switching the rest timer off collapses the sheet to its
    /// header and Done button, as in the "Rest Timer Off" frame.
    private var showsWheel: Bool { !hasSwitch || isEnabled }

    /// Content height from the design's metrics; used as the sheet's detent so it hugs its content
    /// instead of the system's half-screen `.medium`.
    private var sheetHeight: CGFloat {
        let header: CGFloat = subtitle == nil ? 28 : 48
        let wheel: CGFloat = showsWheel ? Self.blockSpacing + Self.wheelTopInset + Self.rowHeight * 3 : 0
        return Self.verticalPadding + header + wheel + Self.blockSpacing + Self.buttonHeight + Self.verticalPadding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Self.blockSpacing) {
            header

            if showsWheel {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Asset.Color.rowSelected.color)
                        .frame(height: Self.rowHeight)

                    NumberWheel(values: values,
                                selection: $selection,
                                format: { "\($0)s" },
                                visibleRows: 3,
                                rowHeight: Self.rowHeight,
                                boldIdleRows: true)
                }
                .frame(height: Self.rowHeight * 3)
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.top, Self.wheelTopInset)
            }

            Button { onDone(isEnabled, selection) } label: {
                Text("Done")
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.white.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: Self.buttonHeight)
                    .background(Asset.Color.mainColor.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, Layout.Spacing.m)
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.vertical, Self.verticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Asset.Color.white.color.ignoresSafeArea())
        // The design's 32pt bottom padding already includes the home-indicator area.
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.easeInOut(duration: 0.2), value: showsWheel)
        .presentationDetents([.height(sheetHeight)])
        .sheetCornerRadius(24)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: Layout.Spacing.s) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title.localizedKey)
                    .font(Typography.subtitleLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                if let subtitle {
                    Text(subtitle.localizedKey)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }

            Spacer(minLength: Layout.Spacing.s)

            if hasSwitch {
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(Asset.Color.mainColor.color)
            }
        }
    }
}

private extension View {
    /// `presentationCornerRadius` needs iOS 16.4; older systems keep the default radius.
    @ViewBuilder
    func sheetCornerRadius(_ radius: CGFloat) -> some View {
        if #available(iOS 16.4, *) {
            presentationCornerRadius(radius)
        } else {
            self
        }
    }
}

#Preview {
    WorkoutSettingsView()
        .preview()
}
