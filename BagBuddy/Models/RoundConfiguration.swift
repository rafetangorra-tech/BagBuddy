import Foundation

struct WorkoutConfiguration: Equatable {
    var discipline: Discipline           = .boxing
    var mode: WorkoutMode                = .noDefense
    var pacing: PacingPreset             = .normal
    var roundDurationSeconds: Int        = 180   // 3 min
    var restDurationSeconds: Int         = 60    // 1 min
    var numberOfRounds: Int              = 6
    var drillDurationSeconds: Int        = 60    // per-combo drill window
    var drillReplayIntervalSeconds: Int  = 15    // how often audio replays in drill
    var warningTimeSeconds: Int          = 10    // 0 = off; fires Warning.mp3 N seconds before round end
    var backgroundMusicEnabled: Bool     = false
    var hapticsEnabled: Bool             = true

    static let `default` = WorkoutConfiguration()
}

// Preserve PacingPreset conformance needed by SessionViewModel
extension PacingPreset: Equatable {}
