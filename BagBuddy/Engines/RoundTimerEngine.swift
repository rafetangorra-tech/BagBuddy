import Foundation
import UIKit
import Combine

/// Manages the full session state machine: countdown → rounds → rest → complete.
/// Handles both call-out mode (No Defense / With Defense) and Drill mode.
@MainActor
final class RoundTimerEngine: ObservableObject {
    @Published var phase: SessionPhase = .idle

    // Current combo being displayed (published for views)
    @Published var currentCombo: Combo? = nil

    // In drill mode: seconds left in the current drill window
    @Published var drillSecondsRemaining: Int = 0

    private var sessionTask: Task<Void, Never>?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    // Pause state — checked by all timing loops
    nonisolated(unsafe) var isPaused: Bool = false

    // Injected by SessionViewModel
    nonisolated(unsafe) var onNeedNextCombo: (() -> Combo?)?
    nonisolated(unsafe) var config: WorkoutConfiguration = .default

    // MARK: - Public

    func pause() {
        isPaused = true
        AudioEngine.shared.pauseCombo()
    }

    func resume() {
        isPaused = false
        AudioEngine.shared.resumeCombo()
    }

    func start(config: WorkoutConfiguration) {
        self.config = config
        stop()
        beginBackgroundTask()
        sessionTask = Task { [weak self] in
            await self?.runSession(config: config)
        }
    }

    func stop() {
        sessionTask?.cancel()
        sessionTask = nil
        currentCombo = nil
        drillSecondsRemaining = 0
        endBackgroundTask()
        phase = .idle
    }

    // MARK: - Session Loop

    private func runSession(config: WorkoutConfiguration) async {
        // 3-2-1 countdown
        for i in stride(from: 3, through: 1, by: -1) {
            guard !Task.isCancelled else { return }
            phase = .countdown(secondsRemaining: i)
            AudioEngine.shared.playCountdownBeep()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        guard !Task.isCancelled else { return }

        for roundNumber in 1...config.numberOfRounds {
            guard !Task.isCancelled else { return }

            AudioEngine.shared.playRoundStart()

            if config.mode == .drill {
                await runDrillRound(number: roundNumber, config: config)
            } else {
                await runCallOutRound(number: roundNumber, config: config)
            }

            guard !Task.isCancelled else { return }
            AudioEngine.shared.playRoundEnd()

            if roundNumber < config.numberOfRounds {
                await runRest(afterRound: roundNumber, duration: config.restDurationSeconds)
                guard !Task.isCancelled else { return }
            }
        }

        guard !Task.isCancelled else { return }
        currentCombo = nil
        phase = .complete
        endBackgroundTask()
    }

    // MARK: - Call-Out Round (No Defense / With Defense)

    private func runCallOutRound(number: Int, config: WorkoutConfiguration) async {
        let roundDuration = Double(config.roundDurationSeconds)
        let startTime     = Date()
        let endTime       = startTime.addingTimeInterval(roundDuration)
        let warningFired  = WarningFlag()

        await withTaskGroup(of: Void.self) { group in
            // Timer countdown task
            group.addTask { [weak self] in
                guard let self else { return }
                for remaining in stride(from: config.roundDurationSeconds, through: 0, by: -1) {
                    guard !Task.isCancelled else { return }
                    await MainActor.run { self.phase = .round(number: number, secondsRemaining: remaining) }
                    if remaining == 0 { break }

                    // Warning bell at 10 seconds
                    let warnAt = config.warningTimeSeconds
                    if warnAt > 0 && remaining == warnAt && !warningFired.value {
                        warningFired.value = true
                        await MainActor.run { AudioEngine.shared.playWarning() }
                    }

                    try? await self.pauseAwareSleep(seconds: 1.0)
                }
            }

            // Combo delivery task
            group.addTask { [weak self] in
                guard let self else { return }
                while Date() < endTime && !Task.isCancelled {
                    guard let combo = self.onNeedNextCombo?() else { break }
                    await MainActor.run { self.currentCombo = combo }
                    let elapsed = Date().timeIntervalSince(startTime)
                    await TimingEngine.shared.cueCombo(
                        combo,
                        pacing: config.pacing,
                        elapsedTime: elapsed,
                        roundLength: roundDuration
                    )
                }
            }

            // When the timer task finishes, cancel the combo task
            await group.next()
            group.cancelAll()
        }
    }

    // MARK: - Drill Round

    private func runDrillRound(number: Int, config: WorkoutConfiguration) async {
        let roundDuration   = Double(config.roundDurationSeconds)
        let drillDuration   = Double(config.drillDurationSeconds)
        let replayInterval  = Double(config.drillReplayIntervalSeconds)
        let roundEndTime    = Date().addingTimeInterval(roundDuration)
        let warningFired    = WarningFlag()

        // Timer task runs independently
        let timerTask = Task { [weak self] in
            guard let self else { return }
            for remaining in stride(from: config.roundDurationSeconds, through: 0, by: -1) {
                guard !Task.isCancelled else { return }
                await MainActor.run { self.phase = .round(number: number, secondsRemaining: remaining) }
                if remaining == 0 { break }

                if remaining == 10 && !warningFired.value {
                    warningFired.value = true
                    await MainActor.run { AudioEngine.shared.playWarning() }
                }

                try? await self.pauseAwareSleep(seconds: 1.0)
            }
        }

        // Drill combo loop
        while Date() < roundEndTime && !Task.isCancelled {
            guard let combo = onNeedNextCombo?() else { break }
            currentCombo = combo

            // Play audio once if available
            if combo.hasAudio {
                await AudioEngine.shared.playCombo(combo)
            }
            guard !Task.isCancelled && Date() < roundEndTime else { break }

            // Drill window with periodic audio replays
            let drillEnd = min(Date().addingTimeInterval(drillDuration), roundEndTime)
            var nextReplay = Date().addingTimeInterval(replayInterval)

            while Date() < drillEnd && !Task.isCancelled {
                let remaining = Int(drillEnd.timeIntervalSinceNow)
                drillSecondsRemaining = max(0, remaining)

                if combo.hasAudio && Date() >= nextReplay && Date() < drillEnd {
                    nextReplay = Date().addingTimeInterval(replayInterval)
                    await AudioEngine.shared.playCombo(combo)
                }

                try? await pauseAwareSleep(seconds: 0.5)
            }

            guard !Task.isCancelled && Date() < roundEndTime else { break }
            AudioEngine.shared.playTransitionBeep()
            try? await pauseAwareSleep(seconds: 0.5)
        }

        timerTask.cancel()
        drillSecondsRemaining = 0
    }

    // MARK: - Rest

    private func runRest(afterRound: Int, duration: Int) async {
        for remaining in stride(from: duration, through: 0, by: -1) {
            guard !Task.isCancelled else { return }
            phase = .rest(afterRound: afterRound, secondsRemaining: remaining)
            if remaining == 0 { break }
            try? await pauseAwareSleep(seconds: 1.0)
        }
    }

    // MARK: - Pause-aware sleep

    /// Sleeps for the given duration in 100ms chunks, halting elapsed time while paused.
    private func pauseAwareSleep(seconds: Double) async throws {
        var elapsed: Double = 0
        while elapsed < seconds {
            guard !Task.isCancelled else { throw CancellationError() }
            if !isPaused {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                elapsed += 0.1
            } else {
                try await Task.sleep(nanoseconds: 100_000_000)
                // don't increment elapsed — time is frozen
            }
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

// Simple non-sendable flag to share across task group tasks
private final class WarningFlag {
    var value = false
}
