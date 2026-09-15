import AVFoundation
import Combine
import Foundation

/// Streams a single background-music track, shared by the pre-workout settings preview and the
/// live workout session so both drive one player instance instead of each managing (and possibly
/// overlapping) their own player.
///
/// Uses `AVPlayer` against the remote URL directly rather than downloading the whole file first --
/// tracks run 3-28 minutes (several MB to tens of MB), so a download-then-play approach leaves
/// the user hearing nothing for a long, connection-dependent stretch before playback can start.
///
/// The live workout session also renders ad units (native ads, and an interstitial around the
/// splash flow elsewhere in the app); ad SDKs commonly reconfigure the shared `AVAudioSession`
/// for their own video creatives, which can silently cut this player off from the audio route.
/// The interruption observer below exists specifically to survive that.
final class BackgroundMusicPlayer: ObservableObject {
    static let shared = BackgroundMusicPlayer()

    @Published private(set) var isPlaying = false
    /// Only meaningful for a caller tracking playback progress (the Profile settings screen's
    /// scrub bar); the session and other previews ignore these.
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private var player: AVPlayer?
    private var currentTrackId: String?
    private var endObserver: NSObjectProtocol?
    private var interruptionObserver: NSObjectProtocol?
    private var timeObserverToken: Any?
    private var durationCancellable: AnyCancellable?
    private var statusCancellable: AnyCancellable?
    private var pendingVolume: Float = 1
    private var onFinished: (() -> Void)?

    init() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            self?.handleInterruption(notification)
        }
    }

    deinit {
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
    }

    /// - Parameters:
    ///   - loop: Workout sessions run longer than any single track, so the session player loops
    ///     the same track; a settings preview just plays through once.
    ///   - onFinished: Called once the track plays to the end, but only when `loop` is false --
    ///     the Profile settings screen uses this to advance to the next track.
    func play(_ track: BackgroundMusic, volume: Float, loop: Bool = false, onFinished: (() -> Void)? = nil) {
        guard let url = URL(string: track.audioUrl) else {
            print("[BackgroundMusicPlayer] Bad audioUrl for \(track.id): \(track.audioUrl)")
            return
        }
        print("[BackgroundMusicPlayer] play(\(track.id)) volume=\(volume) loop=\(loop) url=\(url)")

        pendingVolume = volume
        self.onFinished = onFinished
        activateAudioSession()

        if currentTrackId == track.id, let player {
            player.volume = volume
            player.play()
            isPlaying = true
            return
        }

        stop()
        currentTrackId = track.id

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.volume = volume
        self.player = player

        durationCancellable = item.publisher(for: \.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                guard duration.isNumeric else { return }
                self?.duration = duration.seconds
            }

        // `isPlaying` below reflects that `play()` was called, not that the item actually loaded --
        // an item that fails (network, decode, bad URL response) plays silently with no signal of
        // why. Log its status so a silent track is diagnosable instead of a silent mystery.
        statusCancellable = item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .failed:
                    print("[BackgroundMusicPlayer] Item failed for \(track.id): \(item.error?.localizedDescription ?? "unknown error")")
                case .readyToPlay:
                    print("[BackgroundMusicPlayer] Ready to play \(track.id)")
                default:
                    break
                }
            }

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time.seconds
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self, weak player] _ in
            guard let self else { return }
            if loop {
                player?.seek(to: .zero)
                player?.play()
            } else {
                self.isPlaying = false
                self.onFinished?()
            }
        }

        player.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        guard player != nil else { return }
        activateAudioSession()
        player?.play()
        isPlaying = true
    }

    func setVolume(_ volume: Float) {
        pendingVolume = volume
        player?.volume = volume
    }

    /// Self-heals against silent, hard-to-pin-down interference (a video ad or the exercise demo
    /// clip's own player quietly resetting the shared `AVAudioSession`, without necessarily
    /// firing an interruption notification we'd otherwise catch). Cheap to call repeatedly --
    /// the workout session calls this every second while music should be playing.
    func ensurePlaying() {
        guard isPlaying, let player, player.rate == 0 else { return }
        activateAudioSession()
        player.volume = pendingVolume
        player.play()
    }

    /// Clamped to the track's known duration; a no-op before that duration has arrived.
    func seek(to time: TimeInterval) {
        guard let player, duration > 0 else { return }
        let clamped = max(0, min(time, duration))
        player.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
        currentTime = clamped
    }

    func stop() {
        if let timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        timeObserverToken = nil
        durationCancellable = nil
        statusCancellable = nil
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
        onFinished = nil

        player?.pause()
        player = nil
        currentTrackId = nil
        isPlaying = false
        currentTime = 0
        duration = 0
    }

    /// Re-asserts our category on every play/resume rather than once -- an ad SDK reconfiguring
    /// the shared session later would otherwise leave us silently stuck on whatever it set.
    ///
    /// Plain `.playback`, no options: `.playback` is the category documented to keep playing
    /// with the Ring/Silent switch set to silent, but pairing it with `.mixWithOthers` has been
    /// reported to fall back to respecting the switch on-device, which is exactly the silent
    /// workout session this exists to fix.
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            print("[BackgroundMusicPlayer] Failed to activate audio session: \(error)")
        }
    }

    /// Another audio source (an ad's video creative, a call, Siri) can interrupt the shared
    /// session out from under us. Reclaim it once that source is done, if we were mid-track.
    private func handleInterruption(_ notification: Notification) {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            isPlaying = false
        case .ended:
            guard player != nil else { return }
            let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            guard options.contains(.shouldResume) else { return }
            activateAudioSession()
            player?.volume = pendingVolume
            player?.play()
            isPlaying = true
        @unknown default:
            break
        }
    }
}
