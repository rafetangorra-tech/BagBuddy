import Foundation
import Combine

@MainActor
final class SessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published var phase: SessionPhase = .idle
    @Published var currentCombo: Combo? = nil
    @Published var drillSecondsRemaining: Int = 0
    @Published var combosDelivered: Int = 0
    @Published var isPaused: Bool = false

    // MARK: - Configuration (persisted)

    @Published var config: WorkoutConfiguration = .default {
        didSet {
            saveConfig()
            if oldValue.backgroundMusicEnabled != config.backgroundMusicEnabled {
                if config.backgroundMusicEnabled {
                    AudioEngine.shared.startBackgroundMusic()
                } else {
                    AudioEngine.shared.stopBackgroundMusic()
                }
            }
            if oldValue.hapticsEnabled != config.hapticsEnabled {
                HapticsEngine.shared.isEnabled = config.hapticsEnabled
            }
            if oldValue.notificationsEnabled != config.notificationsEnabled {
                if config.notificationsEnabled {
                    NotificationManager.shared.scheduleDailyReminders()
                } else {
                    NotificationManager.shared.cancelAll()
                }
            }
        }
    }

    // MARK: - Private

    private let roundTimer = RoundTimerEngine()
    private var cancellables = Set<AnyCancellable>()

    // Combo pool for the current session (shuffled, refilled when exhausted)
    private var comboQueue: [Combo] = []

    // MARK: - Init

    init() {
        loadConfig()
        Task {
            await HealthKitManager.shared.requestAuthorization()
            await NotificationManager.shared.requestAuthorization()
        }

        roundTimer.$phase
            .receive(on: RunLoop.main)
            .assign(to: &$phase)

        roundTimer.$currentCombo
            .receive(on: RunLoop.main)
            .assign(to: &$currentCombo)

        roundTimer.$drillSecondsRemaining
            .receive(on: RunLoop.main)
            .assign(to: &$drillSecondsRemaining)

        roundTimer.onNeedNextCombo = { [weak self] in
            self?.nextCombo()
        }

        // Deactivate the audio session when a round completes naturally so the
        // user's music restores to full volume immediately.
        roundTimer.$phase
            .filter { if case .complete = $0 { return true }; return false }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isPaused = false
                AudioEngine.shared.deactivateSession()
            }
            .store(in: &cancellables)
    }

    // MARK: - Session Control

    func startSession() {
        HapticsEngine.shared.isEnabled = config.hapticsEnabled
        AudioEngine.shared.beginSession()
        HealthKitManager.shared.workoutDidStart()
        rebuildPool()
        combosDelivered = 0
        isPaused = false
        roundTimer.start(config: config)

        if config.backgroundMusicEnabled {
            AudioEngine.shared.startBackgroundMusic()
        }
    }

    func stopSession() {
        let record = WorkoutRecord(
            id: UUID(),
            date: Date(),
            discipline: config.discipline.displayName,
            mode: config.mode.displayName,
            numberOfRounds: config.numberOfRounds,
            roundDurationSeconds: config.roundDurationSeconds,
            restDurationSeconds: config.restDurationSeconds,
            combosDelivered: combosDelivered
        )
        if combosDelivered > 0 { HistoryStore.shared.save(record) }

        let c = config
        Task {
            await HealthKitManager.shared.workoutDidEnd(
                discipline: c.discipline,
                roundDuration: c.roundDurationSeconds,
                numberOfRounds: c.numberOfRounds
            )
        }
        roundTimer.stop()
        isPaused = false
        AudioEngine.shared.deactivateSession()
    }

    func pauseSession() {
        isPaused = true
        roundTimer.pause()
    }

    func resumeSession() {
        isPaused = false
        roundTimer.resume()
    }

    func skipCombo() {
        AudioEngine.shared.skipCombo()
    }

    // MARK: - Combo Selection

    private func nextCombo() -> Combo? {
        if comboQueue.isEmpty { rebuildPool() }
        guard !comboQueue.isEmpty else { return nil }
        combosDelivered += 1
        return comboQueue.removeFirst()
    }

    private func rebuildPool() {
        let pool: [Combo]
        if config.mode == .drill {
            pool = ComboService.shared.drillPool(discipline: config.discipline)
        } else if config.mode == .withDefense && config.discipline == .boxing {
            // Boxing Stick & Move: mix in short offensive breakers (1–2 action combos)
            // to interrupt the defense rhythm and keep things realistic.
            let defensive = ComboService.shared.callOutPool(discipline: .boxing, mode: .withDefense)
            let breakers = ComboService.shared.callOutPool(discipline: .boxing, mode: .noDefense)
                .filter { $0.actionCount <= 2 }
            let breakerCount = max(1, defensive.count / 5)
            let selectedBreakers = Array(breakers.shuffled().prefix(breakerCount))
            pool = defensive + selectedBreakers
        } else {
            pool = ComboService.shared.callOutPool(discipline: config.discipline, mode: config.mode)
        }
        comboQueue = pool.shuffled()
    }

    // MARK: - Persistence

    private func saveConfig() {
        let d = UserDefaults.standard
        d.set(config.discipline.rawValue,           forKey: "discipline")
        d.set(config.mode.rawValue,                 forKey: "workoutMode")
        d.set(config.pacing.rawValue,               forKey: "pacing")
        d.set(config.roundDurationSeconds,           forKey: "roundDuration")
        d.set(config.restDurationSeconds,            forKey: "restDuration")
        d.set(config.numberOfRounds,                 forKey: "numberOfRounds")
        d.set(config.drillDurationSeconds,           forKey: "drillDuration")
        d.set(config.warningTimeSeconds,             forKey: "warningTime")
        d.set(config.backgroundMusicEnabled,         forKey: "bgMusic")
        d.set(config.hapticsEnabled,                 forKey: "haptics")
        d.set(config.notificationsEnabled,           forKey: "notifications")
    }

    private func loadConfig() {
        let d = UserDefaults.standard
        var c = WorkoutConfiguration()

        if let raw = d.string(forKey: "discipline"),
           let v = Discipline(rawValue: raw) { c.discipline = v }
        if let raw = d.string(forKey: "workoutMode"),
           let v = WorkoutMode(rawValue: raw) { c.mode = v }
        if let raw = d.string(forKey: "pacing"),
           let v = PacingPreset(rawValue: raw) { c.pacing = v }

        let roundDuration  = d.integer(forKey: "roundDuration")
        let restDuration   = d.integer(forKey: "restDuration")
        let numberOfRounds = d.integer(forKey: "numberOfRounds")
        let drillDuration  = d.integer(forKey: "drillDuration")

        if roundDuration  > 0 { c.roundDurationSeconds = roundDuration }
        if restDuration   > 0 { c.restDurationSeconds  = restDuration }
        if numberOfRounds > 0 { c.numberOfRounds       = numberOfRounds }
        if drillDuration  > 0 { c.drillDurationSeconds = drillDuration }

        let warningTime = d.integer(forKey: "warningTime")
        // 0 is a valid value (warning off), so we only skip the -1 sentinel case
        if d.object(forKey: "warningTime") != nil { c.warningTimeSeconds = warningTime }

        c.backgroundMusicEnabled = d.bool(forKey: "bgMusic")
        c.hapticsEnabled = d.object(forKey: "haptics") == nil ? true : d.bool(forKey: "haptics")
        c.notificationsEnabled = d.bool(forKey: "notifications")

        config = c
    }
}
