import Foundation

enum DifficultyLevel: String, CaseIterable, Identifiable, Codable {
    case beginner     = "Beginner"
    case intermediate = "Intermediate"
    case expert       = "Expert"

    var id: String { rawValue }

    var bpmRange: ClosedRange<Double> {
        switch self {
        case .beginner:     return 60...70
        case .intermediate: return 80...90
        case .expert:       return 100...110
        }
    }

    var defaultBPM: Double {
        switch self {
        case .beginner:     return 65
        case .intermediate: return 85
        case .expert:       return 105
        }
    }

    /// Min/max total moves in a randomly generated combo
    var comboLengthRange: ClosedRange<Int> {
        switch self {
        case .beginner:     return 3...4
        case .intermediate: return 3...5
        case .expert:       return 4...6
        }
    }

    var maxDefenseMoves: Int {
        switch self {
        case .beginner:     return 0
        case .intermediate: return 1
        case .expert:       return 2
        }
    }

    /// Which difficulty levels' library combos are included in this session pool
    var includedLibraryLevels: [DifficultyLevel] {
        switch self {
        case .beginner:     return [.beginner]
        case .intermediate: return [.beginner, .intermediate]
        case .expert:       return [.beginner, .intermediate, .expert]
        }
    }
}
