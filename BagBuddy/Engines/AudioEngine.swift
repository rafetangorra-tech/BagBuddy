import AVFoundation
import Foundation

/// Handles all audio output for Bag Buddy:
///  - Pre-recorded combo call-outs (MP3 files from Audio/Callouts/)
///  - SFX: round bell, warning bell, drill transition beep
///  - Optional background music loop
@MainActor
final class AudioEngine: NSObject {
    static let shared = AudioEngine()

    // MARK: - Private State

    private var comboPlayer:   AVAudioPlayer?
    private var bellPlayer:    AVAudioPlayer?
    private var warningPlayer: AVAudioPlayer?
    private var beepPlayer:    AVAudioPlayer?
    private var musicPlayer:   AVAudioPlayer?

    // Continuations to await combo playback completion
    private var comboContinuation: CheckedContinuation<Void, Never>?

    private override init() {
        super.init()
        configureAudioSession()
        preloadSFX()
    }

    // MARK: - Session Configuration

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                // duckOthers: user's music keeps playing but lowers during call-outs,
                // then restores automatically when BagBuddy audio stops.
                // allowBluetooth / allowBluetoothA2DP: AirPods + A2DP headphones work
                // without the user needing to change anything.
                options: [.duckOthers, .allowBluetooth, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioEngine] Session config failed: \(error)")
        }
    }

    /// Call at the start of every workout to ensure the session is active.
    /// Needed because `deactivateSession()` makes it inactive at the end of a session.
    func beginSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioEngine] Session activation failed: \(error)")
        }
    }

    /// Call when the workout session ends so the system tells Spotify / Apple Music
    /// to restore its full volume immediately.
    func deactivateSession() {
        stopBackgroundMusic()
        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            print("[AudioEngine] Session deactivation failed: \(error)")
        }
    }

    // MARK: - Pre-loading

    private func preloadSFX() {
        bellPlayer    = loadPlayer(resource: "Round Start", ext: "mp3", subdir: "Audio/SFX")
        warningPlayer = loadPlayer(resource: "Warning",     ext: "mp3", subdir: "Audio/SFX")
        // Beep reuses the warning tone at lower volume
        beepPlayer    = loadPlayer(resource: "Warning",     ext: "mp3", subdir: "Audio/SFX")
        beepPlayer?.volume = 0.4
    }

    // MARK: - Combo Playback (awaitable)

    /// Plays the combo audio file and suspends until playback completes.
    /// If `combo.hasAudio` is false or the file is missing, returns immediately.
    func playCombo(_ combo: Combo) async {
        guard combo.hasAudio, let fileName = combo.audioFile else { return }
        let baseName = (fileName as NSString).deletingPathExtension

        guard let url = Bundle.main.url(forResource: baseName, withExtension: "mp3", subdirectory: "Audio/Callouts") else {
            print("[AudioEngine] Missing callout: \(fileName)")
            return
        }

        do {
            comboPlayer?.stop()
            comboPlayer = try AVAudioPlayer(contentsOf: url)
            comboPlayer?.delegate = self
            comboPlayer?.prepareToPlay()
        } catch {
            print("[AudioEngine] Failed to load combo audio: \(error)")
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            comboContinuation = continuation
            comboPlayer?.play()
        }
    }

    func pauseCombo() {
        comboPlayer?.pause()
    }

    func resumeCombo() {
        comboPlayer?.play()
    }

    /// Stops the current combo audio and immediately resolves its awaitable continuation,
    /// so the engine moves on to the next combo without waiting for playback to finish.
    func skipCombo() {
        comboPlayer?.stop()
        comboContinuation?.resume()
        comboContinuation = nil
    }

    // MARK: - SFX

    func playRoundStart() {
        bellPlayer = loadPlayer(resource: "Round Start", ext: "mp3", subdir: "Audio/SFX")
        bellPlayer?.play()
    }

    func playRoundEnd() {
        let player = loadPlayer(resource: "Round End", ext: "mp3", subdir: "Audio/SFX")
        player?.play()
    }

    func playWarning() {
        warningPlayer?.currentTime = 0
        warningPlayer?.play()
    }

    func playTransitionBeep() {
        beepPlayer?.currentTime = 0
        beepPlayer?.play()
    }

    func playCountdownBeep() {
        let player = loadPlayer(resource: "Warning", ext: "mp3", subdir: "Audio/SFX")
        player?.volume = 0.6
        player?.play()
    }

    // MARK: - Background Music

    func startBackgroundMusic() {
        guard musicPlayer == nil else { return }
        guard let url = Bundle.main.url(forResource: "BGLoop", withExtension: "mp3", subdirectory: "Audio/SFX") else { return }
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = -1  // infinite
        musicPlayer?.volume = 0.3
        musicPlayer?.play()
    }

    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    // MARK: - Helpers

    private func loadPlayer(resource: String, ext: String, subdir: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext, subdirectory: subdir) else {
            print("[AudioEngine] Missing: \(subdir)/\(resource).\(ext)")
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioEngine: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.comboContinuation?.resume()
            self.comboContinuation = nil
        }
    }
}
