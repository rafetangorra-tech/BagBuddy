import Foundation

struct ComboLibrary {

    // MARK: - Public API

    static let all: [Combo] = beginnerCombos + intermediateCombos + expertCombos

    static func combos(for difficulty: DifficultyLevel) -> [Combo] {
        difficulty.includedLibraryLevels.flatMap { level in
            all.filter { $0.libraryDifficulty == level }
        }
    }

    // MARK: - Beginner (offense only, 1–4 actions)

    private static let beginnerCombos: [Combo] = [
        // User-provided
        Combo(moves: [.jab, .cross, .leftHook],                                     libraryDifficulty: .beginner, isLibrary: true),  // 1-2-3
        Combo(moves: [.jab, .jab, .cross],                                           libraryDifficulty: .beginner, isLibrary: true),  // 1-1-2
        Combo(moves: [.jab, .cross, .rightUppercut],                                 libraryDifficulty: .beginner, isLibrary: true),  // 1-2-6
        Combo(moves: [.cross, .leftHook, .cross],                                    libraryDifficulty: .beginner, isLibrary: true),  // 2-3-2
        Combo(moves: [.leftHook, .cross, .leftHook],                                 libraryDifficulty: .beginner, isLibrary: true),  // 3-2-3
        Combo(moves: [.jab, .leftUppercut, .cross, .leftHook],                       libraryDifficulty: .beginner, isLibrary: true),  // 1-5-2-3
        // Additional
        Combo(moves: [.jab, .cross],                                                 libraryDifficulty: .beginner, isLibrary: true),  // 1-2
        Combo(moves: [.leftHook, .cross],                                            libraryDifficulty: .beginner, isLibrary: true),  // 3-2
        Combo(moves: [.rightUppercut, .leftHook],                                    libraryDifficulty: .beginner, isLibrary: true),  // 6-3
        Combo(moves: [.jab, .leftUppercut, .cross],                                  libraryDifficulty: .beginner, isLibrary: true),  // 1-5-2
        Combo(moves: [.cross, .leftUppercut, .cross],                                libraryDifficulty: .beginner, isLibrary: true),  // 2-5-2
        Combo(moves: [.leftHook, .cross, .leftUppercut, .cross],                     libraryDifficulty: .beginner, isLibrary: true),  // 3-2-5-2
    ]

    // MARK: - Intermediate (one defensive move, max 5 actions)

    private static let intermediateCombos: [Combo] = [
        // User-provided
        Combo(moves: [.slipLeft, .leftHook, .cross, .leftHook],                      libraryDifficulty: .intermediate, isLibrary: true),  // Slip L-3-2-3
        Combo(moves: [.slipRight, .cross, .leftHook, .cross],                        libraryDifficulty: .intermediate, isLibrary: true),  // Slip R-2-3-2
        Combo(moves: [.jab, .cross, .rollLeft, .leftHook],                           libraryDifficulty: .intermediate, isLibrary: true),  // 1-2-Roll L-3
        Combo(moves: [.jab, .leftUppercut, .rollRight, .cross],                      libraryDifficulty: .intermediate, isLibrary: true),  // 1-5-Roll R-2
        Combo(moves: [.stepBack, .jab, .cross, .leftHook],                           libraryDifficulty: .intermediate, isLibrary: true),  // Step Back-1-2-3
        Combo(moves: [.parry, .jab, .cross, .leftUppercut, .cross],                  libraryDifficulty: .intermediate, isLibrary: true),  // Parry-1-2-5-2
        // Additional
        Combo(moves: [.duck, .leftHook, .cross],                                     libraryDifficulty: .intermediate, isLibrary: true),  // Duck-3-2
        Combo(moves: [.jab, .cross, .slipLeft, .leftHook],                           libraryDifficulty: .intermediate, isLibrary: true),  // 1-2-Slip L-3
        Combo(moves: [.stepOffRight, .leftHook, .cross, .leftHook],                  libraryDifficulty: .intermediate, isLibrary: true),  // Step Off-R-3-2-3
        Combo(moves: [.parry, .cross, .leftHook, .cross],                            libraryDifficulty: .intermediate, isLibrary: true),  // Parry-2-3-2
        Combo(moves: [.jab, .cross, .slipRight, .cross],                             libraryDifficulty: .intermediate, isLibrary: true),  // 1-2-Slip R-2
        Combo(moves: [.rollRight, .cross, .leftHook, .cross],                        libraryDifficulty: .intermediate, isLibrary: true),  // Roll R-2-3-2
    ]

    // MARK: - Expert (2+ defensive moves, max 6 actions)

    private static let expertCombos: [Combo] = [
        // User-provided
        Combo(moves: [.slipRight, .cross, .leftHook, .rollLeft, .leftHook],          libraryDifficulty: .expert, isLibrary: true),  // Slip R-2-3-Roll L-3
        Combo(moves: [.jab, .slipLeft, .leftHook, .cross, .rollRight, .cross],       libraryDifficulty: .expert, isLibrary: true),  // 1-Slip L-3-2-Roll R-2
        Combo(moves: [.jab, .cross, .duck, .rightUppercut, .leftHook],               libraryDifficulty: .expert, isLibrary: true),  // 1-2-Duck-6-3
        Combo(moves: [.slipLeft, .leftHook, .rightHook, .rollRight, .cross],         libraryDifficulty: .expert, isLibrary: true),  // Slip L-3-4-Roll R-2
        Combo(moves: [.stepOffRight, .cross, .leftHook, .cross, .slipLeft],          libraryDifficulty: .expert, isLibrary: true),  // Step Off-R-2-3-2-Slip L
        Combo(moves: [.jab, .stepBack, .cross, .leftHook, .rollLeft, .leftHook],     libraryDifficulty: .expert, isLibrary: true),  // 1-Step Back-2-3-Roll L-3
        // Additional — solo/short calls as pattern-breakers
        Combo(moves: [.jab],                                                         libraryDifficulty: .expert, isLibrary: true),  // 1 solo
        Combo(moves: [.cross],                                                        libraryDifficulty: .expert, isLibrary: true),  // 2 solo
        Combo(moves: [.jab, .cross],                                                 libraryDifficulty: .expert, isLibrary: true),  // 1-2 at speed
        Combo(moves: [.slipLeft, .leftHook, .cross, .rollLeft, .leftHook],           libraryDifficulty: .expert, isLibrary: true),  // Slip L-3-2-Roll L-3
        Combo(moves: [.jab, .duck, .cross, .slipLeft, .leftHook],                   libraryDifficulty: .expert, isLibrary: true),  // 1-Duck-2-Slip L-3
        Combo(moves: [.stepOffRight, .cross, .rollLeft, .leftHook, .cross],          libraryDifficulty: .expert, isLibrary: true),  // Step Off-R-2-Roll L-3-2
    ]
}
