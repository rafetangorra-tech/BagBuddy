import Foundation

/// Drives the beat-by-beat combo cuing loop within a round.
/// Runs as an async Task; cancellable at any time.
@MainActor
final class TimingEngine {
    static let shared = TimingEngine()
    private init() {}

    /// Cues a single combo beat-by-beat, then waits the execution window.
    /// Calls `onMoveIndex` on the main actor for each beat, then `onExecutionWindow` after.
    func cueCombo(
        _ combo: Combo,
        bpm: Double,
        onMoveIndex: @escaping (Int) -> Void,
        onExecutionWindow: @escaping () -> Void
    ) async {
        let beatInterval = 60.0 / bpm
        let beatNanos = UInt64(beatInterval * 1_000_000_000)
        let execNanos  = UInt64(combo.executionWindowSeconds * 1_000_000_000)

        for (index, move) in combo.moves.enumerated() {
            guard !Task.isCancelled else { return }
            onMoveIndex(index)
            AudioEngine.shared.playBeat(for: move)
            try? await Task.sleep(nanoseconds: beatNanos)
        }

        guard !Task.isCancelled else { return }
        onExecutionWindow()
        try? await Task.sleep(nanoseconds: execNanos)
    }
}
