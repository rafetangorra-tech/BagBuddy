import Foundation

enum SessionPhase: Equatable {
    case idle
    case countdown(secondsRemaining: Int)
    case round(number: Int, secondsRemaining: Int)
    case rest(afterRound: Int, secondsRemaining: Int)
    case complete

    var isActive: Bool {
        switch self {
        case .round: return true
        default: return false
        }
    }

    var isRest: Bool {
        if case .rest = self { return true }
        return false
    }

    var isCountdown: Bool {
        if case .countdown = self { return true }
        return false
    }
}
