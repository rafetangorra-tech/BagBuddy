import Foundation

struct RoundConfiguration: Equatable {
    var roundDurationSeconds: Int
    var restDurationSeconds: Int
    var numberOfRounds: Int
    var difficulty: DifficultyLevel
    var bpm: Double

    static let `default` = RoundConfiguration(
        roundDurationSeconds: 180,
        restDurationSeconds: 60,
        numberOfRounds: 3,
        difficulty: .beginner,
        bpm: DifficultyLevel.beginner.defaultBPM
    )

    /// Clamps BPM to the selected difficulty's range
    mutating func clampBPM() {
        bpm = min(max(bpm, difficulty.bpmRange.lowerBound), difficulty.bpmRange.upperBound)
    }
}
