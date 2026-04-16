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
    private var coachPlayer:   AVAudioPlayer?

    // Continuations to await playback completion
    private var comboContinuation: CheckedContinuation<Void, Never>?
    private var coachContinuation: CheckedContinuation<Void, Never>?

    private static let coachFiles = [
        "HandsUp", "KeepThePressureOn", "MakeItCount",
        "PushThrough", "StayBusy", "WatchYourGuard"
    ]

    private override init() {
        super.init()
        configureAudioSession()
        preloadSFX()
    }

    // MARK: - Session Configuration

    private func configureAudioSession() {
        applyMixCategory()
    }

    private func applyMixCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                // mixWithOthers: user's music plays alongside our callouts.
                // duckOthers: temporarily reduces music volume while our audio plays,
                // then restores it between combos (Siri-style duck-and-restore).
                // allowBluetoothA2DP: AirPods / A2DP headphones output.
                options: [.mixWithOthers, .duckOthers, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioEngine] Session config failed: \(error)")
        }
    }

    /// Session is configured once at app init and stays active for the app's lifetime.
    /// With mixWithOthers, we never interrupt other audio, so there's nothing to
    /// re-activate. Re-activating was causing music apps to pause at round start.
    func beginSession() {
        // no-op
    }

    /// Stops our own audio but leaves the session active so music apps keep playing.
    func deactivateSession() {
        stopBackgroundMusic()
        skipCombo()
        stopCoachLine()
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
            comboPlayer?.volume = 1.0
            comboPlayer?.prepareToPlay()
        } catch {
            print("[AudioEngine] Failed to load combo audio: \(error)")
            return
        }

        // Watchdog: if the delegate never fires (audio session interruption, etc.),
        // force-resolve the continuation so the session task can never permanently hang.
        let duration = comboPlayer?.duration ?? 3.0
        let watchdog = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(duration + 1.5, 4.0) * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                if self.comboContinuation != nil {
                    self.comboPlayer?.stop()
                    self.comboContinuation?.resume()
                    self.comboContinuation = nil
                }
            }
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            comboContinuation = continuation
            if comboPlayer?.play() == false {
                comboContinuation?.resume()
                comboContinuation = nil
            }
        }
        watchdog.cancel()
    }

    /// Plays a random coach cue and suspends until it finishes.
    /// Only called after combo audio + gap have fully completed — never overlaps.
    func playCoachLine() async {
        guard let name = Self.coachFiles.randomElement(),
              let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Audio/CoachCues")
        else { return }

        do {
            coachPlayer?.stop()
            coachPlayer = try AVAudioPlayer(contentsOf: url)
            coachPlayer?.delegate = self
            coachPlayer?.volume = 0.55
            coachPlayer?.prepareToPlay()
        } catch {
            print("[AudioEngine] Failed to load coach cue: \(error)")
            return
        }

        let duration = coachPlayer?.duration ?? 2.0
        let watchdog = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(duration + 1.5, 4.0) * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                if self.coachContinuation != nil {
                    self.coachPlayer?.stop()
                    self.coachContinuation?.resume()
                    self.coachContinuation = nil
                }
            }
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            coachContinuation = continuation
            if coachPlayer?.play() == false {
                coachContinuation?.resume()
                coachContinuation = nil
            }
        }
        watchdog.cancel()
    }

    /// Force-stops coach audio and resolves any pending continuation.
    func stopCoachLine() {
        coachPlayer?.stop()
        coachContinuation?.resume()
        coachContinuation = nil
    }

    func pauseCombo() {
        comboPlayer?.pause()
        coachPlayer?.pause()
    }

    func resumeCombo() {
        comboPlayer?.play()
        coachPlayer?.play()
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
        // Reassign to bellPlayer so the player isn't deallocated before playback finishes
        bellPlayer = loadPlayer(resource: "Round End", ext: "mp3", subdir: "Audio/SFX")
        bellPlayer?.play()
    }

    func playWarning() {
        // Reload each call to guarantee a valid player on device
        warningPlayer = loadPlayer(resource: "Warning", ext: "mp3", subdir: "Audio/SFX")
        warningPlayer?.play()
    }

    func playTransitionBeep() {
        beepPlayer?.currentTime = 0
        beepPlayer?.play()
    }

    func playCountdownBeep() {
        beepPlayer = loadPlayer(resource: "Warning", ext: "mp3", subdir: "Audio/SFX")
        beepPlayer?.volume = 0.6
        beepPlayer?.play()
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
            if player === self.comboPlayer {
                self.comboContinuation?.resume()
                self.comboContinuation = nil
            } else if player === self.coachPlayer {
                self.coachContinuation?.resume()
                self.coachContinuation = nil
            }
        }
    }
}
