import Foundation

// MARK: - Move Type

enum MoveType {
    case strike
    case defense
}

// MARK: - Move

enum Move: String, CaseIterable, Codable, Identifiable, Hashable {
    // Strikes
    case jab           = "1"
    case cross         = "2"
    case leftHook      = "3"
    case rightHook     = "4"
    case leftUppercut  = "5"
    case rightUppercut = "6"

    // Defense
    case slipLeft    = "Slip L"
    case slipRight   = "Slip R"
    case rollLeft    = "Roll L"
    case rollRight   = "Roll R"
    case stepBack    = "Step Back"
    case stepOffRight = "Step Off-R"
    case parry       = "Parry"
    case duck        = "Duck"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var type: MoveType {
        switch self {
        case .jab, .cross, .leftHook, .rightHook, .leftUppercut, .rightUppercut:
            return .strike
        default:
            return .defense
        }
    }

    /// If this defense move constrains which strikes are valid next, returns that set.
    /// nil means no constraint.
    var constrainsNextStrikeTo: [Move]? {
        switch self {
        case .slipLeft, .rollLeft:
            return [.leftHook, .leftUppercut]   // lead-hand strikes
        case .slipRight, .rollRight:
            return [.cross, .rightUppercut]     // rear-hand strikes
        default:
            return nil
        }
    }
}

// MARK: - Convenience Sets

extension Move {
    static let allStrikes: [Move] = [.jab, .cross, .leftHook, .rightHook, .leftUppercut, .rightUppercut]
    static let leadHandStrikes: [Move] = [.leftHook, .leftUppercut]
    static let rearHandStrikes: [Move] = [.cross, .rightUppercut]
    static let allDefense: [Move] = [.slipLeft, .slipRight, .rollLeft, .rollRight,
                                      .stepBack, .stepOffRight, .parry, .duck]
}
