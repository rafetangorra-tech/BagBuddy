import Foundation

// MARK: - Discipline

enum Discipline: String, Codable, CaseIterable, Identifiable {
    case boxing   = "boxing"
    case muayThai = "muayThai"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .boxing:   return "Boxing"
        case .muayThai: return "Muay Thai"
        }
    }
}

// MARK: - WorkoutMode

enum WorkoutMode: String, Codable, CaseIterable, Identifiable {
    case noDefense   = "noDefense"
    case withDefense = "withDefense"
    case drill       = "drill"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .noDefense:   return "Stand and Bang"
        case .withDefense: return "Stick and Move"
        case .drill:       return "Drillers Make Killers"
        }
    }

    /// Short label used in mode pills during workout
    var pillLabel: String {
        switch self {
        case .noDefense:   return "STAND & BANG"
        case .withDefense: return "STICK & MOVE"
        case .drill:       return "DRILLERS"
        }
    }

    var description: String {
        switch self {
        case .noDefense:   return "Offense-only combos, called out back to back"
        case .withDefense: return "Combos with a defensive move included"
        case .drill:       return "One complex combo — drill it for 60 seconds"
        }
    }
}

// MARK: - Pacing

enum PacingPreset: String, CaseIterable, Identifiable {
    case relaxed, normal, push

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .relaxed: return "Relaxed"
        case .normal:  return "Normal"
        case .push:    return "Push"
        }
    }

    /// Global delay multiplier applied to the timing formula.
    var multiplier: Double {
        switch self {
        case .relaxed: return 1.3
        case .normal:  return 1.0
        case .push:    return 0.8
        }
    }
}

// MARK: - Combo

struct Combo: Codable, Identifiable, Hashable {
    let code: String
    let discipline: Discipline
    let mode: WorkoutMode
    let combination: String
    let actionCount: Int
    let hasAudio: Bool
    let audioFile: String?

    var id: String { code }

    /// "1 · 2 · 3" — separator formatted for display
    var displayCombination: String {
        combination.replacingOccurrences(of: " - ", with: " · ")
    }

    /// "Jab · Cross · Lead Hook" — numbers expanded to names
    var expandedCombination: String {
        combination
            .components(separatedBy: " - ")
            .map(Self.expandToken)
            .joined(separator: " · ")
    }

    // MARK: - Defense / Strike Segmentation

    /// Breaks the combination into typed segments for layered display.
    /// Defense moves get their own segment (shown smaller), strikes group together (shown large).
    var segments: [ComboSegment] {
        let tokens = combination.components(separatedBy: " - ")
        guard !tokens.isEmpty else { return [] }

        var result: [ComboSegment] = []
        var currentIsDefense = Self.isDefenseToken(tokens[0])
        var currentTokens: [String] = []

        for token in tokens {
            let tokenIsDefense = Self.isDefenseToken(token)
            if tokenIsDefense == currentIsDefense {
                currentTokens.append(token)
            } else {
                result.append(ComboSegment(isDefense: currentIsDefense, tokens: currentTokens))
                currentIsDefense = tokenIsDefense
                currentTokens = [token]
            }
        }
        if !currentTokens.isEmpty {
            result.append(ComboSegment(isDefense: currentIsDefense, tokens: currentTokens))
        }
        return result
    }

    private static let defenseTokens: Set<String> = [
        "Slip L", "Slip R", "Roll L", "Roll R",
        "Step Back", "Step Off-L", "Step Off-R",
        "Duck", "Check L", "Check R", "Catch"
    ]

    /// Muay Thai kicks and knees — 350ms base + 100ms body-movement surcharge = 450ms each.
    private static let kickKneeTokens: Set<String> = [
        "Knee L", "Knee R",
        "Low Kick L", "Low Kick R",
        "Body Kick L", "Body Kick R"
    ]

    static func isDefenseToken(_ token: String) -> Bool {
        defenseTokens.contains(token)
    }

    /// Total body-execution time for this combo in seconds.
    ///
    /// Formula per token:
    /// - Defensive move → 500ms
    /// - MT kick / knee → 450ms (350ms + 100ms for larger body displacement)
    /// - All other strikes → 350ms
    var executionTime: Double {
        combination.components(separatedBy: " - ").reduce(0.0) { sum, token in
            if Self.defenseTokens.contains(token) {
                return sum + 0.50
            } else if Self.kickKneeTokens.contains(token) && discipline == .muayThai {
                return sum + 0.45
            } else {
                return sum + 0.35
            }
        }
    }

    private static func expandToken(_ token: String) -> String {
        switch token {
        case "1": return "Jab"
        case "2": return "Cross"
        case "3": return "Lead Hook"
        case "4": return "Rear Hook"
        case "5": return "Lead Uppercut"
        case "6": return "Rear Uppercut"
        default:  return token
        }
    }
}

// MARK: - Combo Database

struct ComboDB: Codable {
    let combos: [Combo]
}

// MARK: - Combo Segment

struct ComboSegment {
    let isDefense: Bool
    let tokens: [String]

    /// Display text: tokens joined with " - "
    var text: String {
        tokens.joined(separator: " - ").uppercased()
    }
}
