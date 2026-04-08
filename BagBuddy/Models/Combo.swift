import Foundation

struct Combo: Identifiable, Equatable, Hashable {
    let id: UUID
    let moves: [Move]
    let libraryDifficulty: DifficultyLevel  // difficulty this combo was authored for
    let isLibrary: Bool

    init(moves: [Move], libraryDifficulty: DifficultyLevel, isLibrary: Bool = false) {
        self.id = UUID()
        self.moves = moves
        self.libraryDifficulty = libraryDifficulty
        self.isLibrary = isLibrary
    }

    /// Display string: "1 - 2 - Slip R - 3"
    var displayText: String {
        moves.map(\.displayName).joined(separator: "  —  ")
    }

    var length: Int { moves.count }

    /// Execution window after the combo is fully cued, in seconds
    var executionWindowSeconds: Double {
        Double(length) * 1.5
    }
}
