import AVFoundation
import Foundation

final class AudioEngine {
    static let shared = AudioEngine()

    private var players: [String: [AVAudioPlayer]] = [:]
    private let poolSize = 4

    private init() {
        configureSession()
        preload("tick_high", count: poolSize)
        preload("tick_low",  count: poolSize)
        preload("bell",      count: 2)
    }

    // MARK: - Public

    func playStrikeCue() {
        play("tick_high")
    }

    func playDefenseCue() {
        play("tick_low")
    }

    func playBeat(for move: Move) {
        move.type == .strike ? playStrikeCue() : playDefenseCue()
    }

    func playBell() {
        play("bell")
    }

    func playCountdownBeep() {
        play("tick_high")
    }

    // MARK: - Private

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioEngine] Session config failed: \(error)")
        }
    }

    private func preload(_ name: String, count: Int) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("[AudioEngine] Missing audio file: \(name).wav")
            return
        }
        players[name] = (0..<count).compactMap { _ in
            let p = try? AVAudioPlayer(contentsOf: url)
            p?.prepareToPlay()
            return p
        }
    }

    private func play(_ name: String) {
        guard let pool = players[name], !pool.isEmpty else { return }
        let player = pool.first(where: { !$0.isPlaying }) ?? pool.first!
        player.play()
    }
}
