import Foundation

/// Drives the combo call-out loop for No Defense and With Defense modes.
///
/// Delay formula (fires AFTER audio clip finishes):
///   Delay = (ProcessingBuffer + ExecutionTime) × PacingMultiplier × FatigueMultiplier × Jitter
///
/// - ProcessingBuffer: 300ms constant (auditory decoding + motor planning)
/// - ExecutionTime: sum of per-token times — 500ms defensive, 450ms MT kick/knee, 350ms all other strikes
/// - PacingMultiplier: Relaxed 1.3 / Normal 1.0 / Push 0.8
/// - FatigueMultiplier: 1.0 first half of round, 1.2 second half
/// - Jitter: random ±15% (0.85–1.15) to prevent rhythm anticipation
@MainActor
final class TimingEngine {
    static let shared = TimingEngine()
    private init() {}

    /// Plays `combo` audio then waits the calculated execution delay before returning.
    ///
    /// - Parameters:
    ///   - combo: The combo to cue.
    ///   - pacing: User-selected pacing preset.
    ///   - elapsedTime: Seconds elapsed since the round started (drives fatigue multiplier).
    ///   - roundLength: Total round duration in seconds.
    func cueCombo(
        _ combo: Combo,
        pacing: PacingPreset,
        elapsedTime: Double,
        roundLength: Double
    ) async {
        guard !Task.isCancelled else { return }

        // Play audio — suspends until clip finishes
        await AudioEngine.shared.playCombo(combo)

        guard !Task.isCancelled else { return }

        let delay = calculateDelay(
            combo: combo,
            pacing: pacing,
            elapsedTime: elapsedTime,
            roundLength: roundLength
        )
        let delayNanos = UInt64(max(0, delay) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: delayNanos)
    }

    // MARK: - Formula

    private func calculateDelay(
        combo: Combo,
        pacing: PacingPreset,
        elapsedTime: Double,
        roundLength: Double
    ) -> Double {
        let processingBuffer = 0.3   // 300ms constant

        let baseDelay = processingBuffer + combo.executionTime

        // Pacing: Relaxed 1.3×, Normal 1.0×, Push 0.8×
        let pacingMultiplier = pacing.multiplier

        // Fatigue: back half of the round slows delivery by 20% to
        // account for degraded auditory reaction time under CV load
        let fatigueMultiplier: Double = elapsedTime > (roundLength / 2) ? 1.2 : 1.0

        // Jitter: ±15% randomisation prevents rhythm anticipation
        let jitter = Double.random(in: 0.85...1.15)

        return baseDelay * pacingMultiplier * fatigueMultiplier * jitter
    }
}
