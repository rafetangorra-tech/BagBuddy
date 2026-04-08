import Foundation

struct ComboGenerator {

    static func generate(for difficulty: DifficultyLevel) -> Combo {
        var moves: [Move] = []
        let length = Int.random(in: difficulty.comboLengthRange)
        var defenseCount = 0
        let maxDefense = difficulty.maxDefenseMoves

        // First move: always a strike (natural boxing convention)
        moves.append(Move.allStrikes.randomElement()!)

        while moves.count < length {
            let slotsLeft = length - moves.count
            let defenseRemaining = maxDefense - defenseCount
            let lastMove = moves.last!
            let lastWasDefense = lastMove.type == .defense

            // Determine if we must throw a strike
            let mustBeStrike = lastWasDefense || defenseRemaining == 0

            if mustBeStrike {
                moves.append(nextStrike(after: lastMove))
            } else {
                // 30% chance to insert a defense move when budget allows
                let insertDefense = defenseRemaining > 0 && Double.random(in: 0...1) < 0.30
                if insertDefense {
                    moves.append(Move.allDefense.randomElement()!)
                    defenseCount += 1
                } else {
                    moves.append(nextStrike(after: lastMove))
                }
            }
        }

        return Combo(moves: moves, libraryDifficulty: difficulty, isLibrary: false)
    }

    // MARK: - Private

    /// Returns a valid strike to follow the given move, respecting direction constraints.
    private static func nextStrike(after previous: Move) -> Move {
        if let allowed = previous.constrainsNextStrikeTo {
            return allowed.randomElement()!
        }
        return Move.allStrikes.randomElement()!
    }
}
