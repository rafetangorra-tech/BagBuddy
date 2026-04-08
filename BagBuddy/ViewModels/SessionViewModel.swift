import Foundation
import Combine

@MainActor
final class SessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published var phase: SessionPhase = .idle
    @Published var currentCombo: Combo? = nil
    @Published var currentMoveIndex: Int? = nil
    @Published var isExecutionWindow: Bool = false
    @Published var combosDelivered: Int = 0

    // MARK: - Settings (persisted via UserDefaults)

    @Published var config: RoundConfiguration = .default {
        didSet { saveConfig() }
    }

    // MARK: - Private

    private let roundTimer = RoundTimerEngine()
    private var cancellables = Set<AnyCancellable>()

    private var libraryQueue: [Combo] = []
    private var usedSignatures: [String] = []
    private var useLibraryNext = true

    // MARK: - Init

    init() {
        loadConfig()

        // Forward round timer phase to our phase
        roundTimer.$phase
            .receive(on: RunLoop.main)
            .sink { [weak self] newPhase in
                self?.phase = newPhase
            }
            .store(in: &cancellables)

        // Wire callbacks
        roundTimer.onNeedNextCombo = { [weak self] in
            self?.nextCombo() ?? Combo(moves: [.jab], libraryDifficulty: .beginner)
        }
        roundTimer.onMoveIndex = { [weak self] idx in
            self?.currentMoveIndex = idx
            self?.isExecutionWindow = false
        }
        roundTimer.onExecutionWindow = { [weak self] in
            self?.currentMoveIndex = nil
            self?.isExecutionWindow = true
        }
    }

    // MARK: - Session Control

    func startSession() {
        resetQueues()
        combosDelivered = 0
        roundTimer.start(config: config)
    }

    func stopSession() {
        roundTimer.stop()
        currentCombo = nil
        currentMoveIndex = nil
        isExecutionWindow = false
    }

    // MARK: - Combo Selection

    func nextCombo() -> Combo {
        combosDelivered += 1
        let candidate: Combo

        if useLibraryNext, !libraryQueue.isEmpty {
            candidate = libraryQueue.removeFirst()
        } else {
            candidate = ComboGenerator.generate(for: config.difficulty)
        }
        useLibraryNext.toggle()

        // Dedup: regenerate if this signature appeared in last 10
        let sig = candidate.displayText
        if usedSignatures.suffix(10).contains(sig) {
            let fresh = ComboGenerator.generate(for: config.difficulty)
            usedSignatures.append(fresh.displayText)
            currentCombo = fresh
            return fresh
        }

        usedSignatures.append(sig)
        if usedSignatures.count > 20 { usedSignatures.removeFirst() }
        currentCombo = candidate
        return candidate
    }

    // MARK: - Private Helpers

    private func resetQueues() {
        usedSignatures = []
        useLibraryNext = true
        libraryQueue = ComboLibrary.combos(for: config.difficulty).shuffled()
    }

    // MARK: - Persistence

    private func saveConfig() {
        UserDefaults.standard.set(config.roundDurationSeconds, forKey: "roundDuration")
        UserDefaults.standard.set(config.restDurationSeconds,  forKey: "restDuration")
        UserDefaults.standard.set(config.numberOfRounds,       forKey: "numberOfRounds")
        UserDefaults.standard.set(config.difficulty.rawValue,  forKey: "difficulty")
        UserDefaults.standard.set(config.bpm,                  forKey: "bpm")
    }

    private func loadConfig() {
        let roundDuration  = UserDefaults.standard.integer(forKey: "roundDuration")
        let restDuration   = UserDefaults.standard.integer(forKey: "restDuration")
        let numberOfRounds = UserDefaults.standard.integer(forKey: "numberOfRounds")
        let difficultyRaw  = UserDefaults.standard.string(forKey: "difficulty")
        let bpm            = UserDefaults.standard.double(forKey: "bpm")

        let difficulty = DifficultyLevel(rawValue: difficultyRaw ?? "") ?? .beginner

        config = RoundConfiguration(
            roundDurationSeconds: roundDuration > 0 ? roundDuration : 180,
            restDurationSeconds:  restDuration  > 0 ? restDuration  : 60,
            numberOfRounds:       numberOfRounds > 0 ? numberOfRounds : 3,
            difficulty:           difficulty,
            bpm:                  bpm > 0 ? bpm : difficulty.defaultBPM
        )
    }
}
