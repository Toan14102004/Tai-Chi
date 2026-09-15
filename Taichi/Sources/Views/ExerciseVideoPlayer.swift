//
//  ExerciseVideoPlayer.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import AVFoundation
import SwiftUI
import UIKit

/// Silent demo clip for one exercise (`media.videoUrl`), roughly as long as the exercise itself.
/// Plays through once and holds on the last frame rather than looping. Transport controls stay out
/// of the way -- they sit over the middle of the frame, which is exactly where the movement is --
/// so they appear on tap and hide themselves again; only the thin progress line is always visible.
struct ExerciseVideoPlayer: UIViewRepresentable {
    enum Mode: Equatable {
        /// Exercise Detail: play once, transport controls, hold on the last frame.
        case browsing
        /// Session player: loop silently for as long as the exercise timer runs, with no controls
        /// of its own -- the session owns pause, and a second set of buttons would compete with it.
        case session(isPaused: Bool)
    }

    let url: URL
    var mode: Mode = .browsing
    /// Fires `true` while the clip is actually moving and `false` when it's paused or has
    /// played through to the end -- lets a host screen (Exercise Detail) keep its own
    /// background music in step with the demo clip rather than looping on regardless.
    var onPlaybackStateChange: ((Bool) -> Void)?
    /// Fires when the video reaches the end (browsing mode only).
    var onPlaybackEnded: (() -> Void)?

    func makeUIView(context _: Context) -> ExerciseClipView {
        let view = ExerciseClipView()
        view.configure(url: url, mode: mode, onPlaybackStateChange: onPlaybackStateChange, onPlaybackEnded: onPlaybackEnded)
        return view
    }

    func updateUIView(_ uiView: ExerciseClipView, context _: Context) {
        uiView.configure(url: url, mode: mode, onPlaybackStateChange: onPlaybackStateChange, onPlaybackEnded: onPlaybackEnded)
    }

    static func dismantleUIView(_ uiView: ExerciseClipView, coordinator _: ()) {
        uiView.stop()
    }
}

final class ExerciseClipView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private enum PlaybackState {
        case playing
        case paused
        case ended
    }

    private static let skipInterval: Double = 5
    private static let autoHideDelay: TimeInterval = 2.5

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var endObserver: NSObjectProtocol?
    private var timeObserver: Any?
    private var currentURL: URL?
    private var hideWork: DispatchWorkItem?
    private var mode: ExerciseVideoPlayer.Mode = .browsing
    private var onPlaybackStateChange: ((Bool) -> Void)?
    private var onPlaybackEnded: (() -> Void)?

    private var state: PlaybackState = .paused {
        didSet {
            updatePlayPauseIcon()
            onPlaybackStateChange?(state == .playing)
            if state == .ended {
                onPlaybackEnded?()
            }
        }
    }

    private let controlsRow = UIStackView()
    private let backwardButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)

    private let progressTrack = UIView()
    private let progressFill = UIView()
    private var progressFillWidth: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
        setupProgressBar()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Playback

    func configure(url: URL, mode: ExerciseVideoPlayer.Mode, onPlaybackStateChange: ((Bool) -> Void)? = nil, onPlaybackEnded: (() -> Void)? = nil) {
        self.onPlaybackStateChange = onPlaybackStateChange
        self.onPlaybackEnded = onPlaybackEnded

        if url == currentURL {
            apply(mode: mode)
            return
        }
        currentURL = url
        self.mode = mode
        stop()

        let player = AVPlayer(url: url)
        player.isMuted = true
        player.actionAtItemEnd = .pause

        let isSession = mode != .browsing
        controlsRow.isHidden = isSession
        progressTrack.isHidden = true

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            // In a session the clip is a looping demo for as long as the exercise timer runs.
            if case .session = self.mode {
                player.seek(to: .zero)
                player.play()
                return
            }
            state = .ended
            setProgress(1)
            showControls(autoHide: false)
        }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            // Self-heals against an ad SDK reconfiguring the shared AVAudioSession for its own
            // video creative -- BackgroundMusicPlayer documents the same interference and
            // recovers from it; this muted clip player sat unprotected, silently stuck at rate 0
            // with no interruption notification it was listening for. Cheap to check ten times a
            // second, and only acts when playback thinks it should be moving but the player isn't.
            if state == .playing, player.rate == 0 {
                player.play()
            }
            guard let duration = player.currentItem?.duration.seconds,
                  duration.isFinite, duration > 0 else { return }
            setProgress(time.seconds / duration)
        }

        if case let .session(isPaused) = mode {
            // Reduce Motion is not honoured here: the clip is the instruction for a move the user
            // is doing right now, and the session's own timer is already running.
            state = isPaused ? .paused : .playing
            if !isPaused { player.play() }
            return
        }

        // Someone who has asked the system for less motion should not get a clip starting on its
        // own; it waits paused on the first frame, controls visible so play is one tap away.
        if UIAccessibility.isReduceMotionEnabled {
            state = .paused
            showControls(autoHide: false)
        } else {
            state = .playing
            player.play()
            // Shown briefly on open so the controls are discoverable, then out of the way.
            showControls(autoHide: true)
        }
    }

    /// Follows the session's pause state without rebuilding the player.
    private func apply(mode newMode: ExerciseVideoPlayer.Mode) {
        guard mode != newMode else { return }
        mode = newMode
        guard case let .session(isPaused) = newMode, let player = playerLayer.player else { return }

        if isPaused {
            player.pause()
            state = .paused
        } else {
            player.play()
            state = .playing
        }
    }

    func stop() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        if let timeObserver {
            playerLayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        hideWork?.cancel()
        playerLayer.player?.pause()
        playerLayer.player = nil
        setProgress(0)
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        hideWork?.cancel()
    }

    // MARK: - Controls visibility

    @objc private func viewTapped() {
        guard mode == .browsing else { return }
        if controlsRow.alpha > 0 {
            hideControls()
        } else {
            showControls(autoHide: state == .playing)
        }
    }

    private func showControls(autoHide: Bool) {
        hideWork?.cancel()
        UIView.animate(withDuration: 0.2) { self.controlsRow.alpha = 1 }

        guard autoHide else { return }
        let work = DispatchWorkItem { [weak self] in self?.hideControls() }
        hideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.autoHideDelay, execute: work)
    }

    private func hideControls() {
        hideWork?.cancel()
        UIView.animate(withDuration: 0.2) { self.controlsRow.alpha = 0 }
    }

    // MARK: - Layout

    private func setupControls() {
        configure(button: backwardButton, symbol: "gobackward.5", diameter: 40, pointSize: 17)
        configure(button: playPauseButton, symbol: "pause.fill", diameter: 52, pointSize: 22)
        configure(button: forwardButton, symbol: "goforward.5", diameter: 40, pointSize: 17)

        backwardButton.accessibilityLabel = NSLocalizedString("Back 5 seconds", comment: "Rewind the exercise clip")
        forwardButton.accessibilityLabel = NSLocalizedString("Forward 5 seconds", comment: "Skip ahead in the exercise clip")

        backwardButton.addTarget(self, action: #selector(seekBackward), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(seekForward), for: .touchUpInside)

        controlsRow.axis = .horizontal
        controlsRow.alignment = .center
        controlsRow.spacing = 20
        controlsRow.alpha = 0
        controlsRow.translatesAutoresizingMaskIntoConstraints = false
        [backwardButton, playPauseButton, forwardButton].forEach(controlsRow.addArrangedSubview)

        addSubview(controlsRow)
        NSLayoutConstraint.activate([
            controlsRow.centerXAnchor.constraint(equalTo: centerXAnchor),
            controlsRow.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupProgressBar() {
        progressTrack.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        progressFill.backgroundColor = Asset.Color.mainColor.uiColor
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        progressFill.translatesAutoresizingMaskIntoConstraints = false

        addSubview(progressTrack)
        progressTrack.addSubview(progressFill)

        progressFillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressTrack.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressTrack.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressTrack.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressTrack.heightAnchor.constraint(equalToConstant: 3),

            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressFillWidth
        ])
    }

    private func setProgress(_ fraction: Double) {
        let clamped = min(max(fraction, 0), 1)
        progressFillWidth.constant = bounds.width * clamped
    }

    private func configure(button: UIButton, symbol: String, diameter: CGFloat, pointSize: CGFloat) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(systemName: symbol,
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)),
            for: .normal
        )
        button.tintColor = Asset.Color.white.uiColor
        button.backgroundColor = Asset.Color.mainColor.uiColor
        button.layer.cornerRadius = diameter / 2
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: diameter),
            button.heightAnchor.constraint(equalToConstant: diameter)
        ])
    }

    private func updatePlayPauseIcon() {
        let symbol: String
        let label: String
        switch state {
        case .playing:
            symbol = "pause.fill"
            label = NSLocalizedString("Pause", comment: "Pause the exercise clip")
        case .paused:
            symbol = "play.fill"
            label = NSLocalizedString("Play", comment: "Play the exercise clip")
        case .ended:
            symbol = "arrow.counterclockwise"
            label = NSLocalizedString("Replay", comment: "Replay the exercise clip")
        }

        playPauseButton.setImage(
            UIImage(systemName: symbol,
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)),
            for: .normal
        )
        playPauseButton.accessibilityLabel = label
    }

    // MARK: - Actions

    @objc private func togglePlayback() {
        guard let player = playerLayer.player else { return }

        switch state {
        case .playing:
            player.pause()
            state = .paused
            showControls(autoHide: false)
        case .paused:
            player.play()
            state = .playing
            showControls(autoHide: true)
        case .ended:
            player.seek(to: .zero)
            player.play()
            state = .playing
            showControls(autoHide: true)
        }
    }

    @objc private func seekBackward() {
        seek(by: -Self.skipInterval)
    }

    @objc private func seekForward() {
        seek(by: Self.skipInterval)
    }

    private func seek(by delta: Double) {
        guard let player = playerLayer.player,
              let duration = player.currentItem?.duration.seconds,
              duration.isFinite, duration > 0 else { return }

        let target = min(max(0, player.currentTime().seconds + delta), duration)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600),
                    toleranceBefore: .zero, toleranceAfter: .zero)
        setProgress(target / duration)

        // Skipping back out of the finished state should resume rather than leave a stalled frame.
        if state == .ended, target < duration {
            player.play()
            state = .playing
        }
        showControls(autoHide: state == .playing)
    }
}
