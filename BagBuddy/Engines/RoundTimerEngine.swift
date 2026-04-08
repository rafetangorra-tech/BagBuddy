import Foundation
import UIKit

/// Manages the full session state machine: countdown → rounds → rest → complete.
/// All published properties update on MainActor.
@MainActor
final class RoundTimerEngine: ObservableObject {
    @Published var phase: SessionPhase = .idle

    private var sessionTask: Task<Void, Never>?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    // Injected from SessionViewModel
    var onNeedNextCombo: (() -> Combo)?
    var onMoveIndex: ((Int) -> Void)?
    var onExecutionWindow: (() -> Void)?

    // MARK: - Public

    func start(config: RoundConfiguration) {
        stop()
        beginBackgroundTask()
        sessionTask = Task { [weak self] in
            await self?.runSession(config: config)
        }
    }

    func stop() {
        sessionTask?.cancel()
        sessionTask = nil
        endBackgroundTask()
        phase = .idle
    }

    // MARK: - Session Loop

    private func runSession(config: RoundConfiguration) async {
        // 3-2-1 countdown
        for i in stride(from: 3, through: 1, by: -1) {
            guard !Task.isCancelled else { return }
            phase = .countdown(secondsRemaining: i)
            AudioEngine.shared.playCountdownBeep()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        guard !Task.isCancelled else { return }
        AudioEngine.shared.playBell()

        for roundNumber in 1...config.numberOfRounds {
            guard !Task.isCancelled else { return }

            // Run round: combo loop + countdown timer in parallel
            await runRound(number: roundNumber, config: config)
            guard !Task.isCancelled else { return }

            AudioEngine.shared.playBell()

            if roundNumber < config.numberOfRounds {
                await runRest(afterRound: roundNumber, duration: config.restDurationSeconds)
                guard !Task.isCancelled else { return }
                AudioEngine.shared.playBell()
            }
        }

        guard !Task.isCancelled else { return }
        phase = .complete
        endBackgroundTask()
    }

    private func runRound(number: Int, config: RoundConfiguration) async {
        let endTime = Date().addingTimeInterval(Double(config.roundDurationSeconds))

        // Combo delivery loop runs until round time expires
        await withTaskGroup(of: Void.self) { group in
            // Timer countdown task
            group.addTask { [weak self] in
                guard let self else { return }
                for remaining in stride(from: config.roundDurationSeconds, through: 0, by: -1) {
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        self.phase = .round(number: number, secondsRemaining: remaining)
                    }
                    if remaining == 0 { break }
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }

            // Combo delivery task
            group.addTask { [weak self] in
                guard let self else { return }
                while Date() < endTime && !Task.isCancelled {
                    guard let combo = await self.onNeedNextCombo?() else { break }
                    await TimingEngine.shared.cueCombo(
                        combo,
                        bpm: config.bpm,
                        onMoveIndex: { [weak self] idx in self?.onMoveIndex?(idx) },
                        onExecutionWindow: { [weak self] in self?.onExecutionWindow?() }
                    )
                }
            }

            // When the timer task finishes, cancel the combo task too
            await group.next()
            group.cancelAll()
        }
    }

    private func runRest(afterRound: Int, duration: Int) async {
        for remaining in stride(from: duration, through: 0, by: -1) {
            guard !Task.isCancelled else { return }
            phase = .rest(afterRound: afterRound, secondsRemaining: remaining)
            if remaining == 0 { break }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    // MARK: - Background

    private func beginBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "BagBuddySession") { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}
