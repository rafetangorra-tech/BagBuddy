import Foundation

struct WorkoutPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var config: WorkoutConfiguration
}
