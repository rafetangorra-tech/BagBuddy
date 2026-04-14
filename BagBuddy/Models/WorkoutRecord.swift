import Foundation

struct WorkoutRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let discipline: String
    let mode: String
    let numberOfRounds: Int
    let roundDurationSeconds: Int
    let restDurationSeconds: Int
    let combosDelivered: Int

    var totalDurationSeconds: Int {
        (roundDurationSeconds * numberOfRounds) + (restDurationSeconds * max(0, numberOfRounds - 1))
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    var formattedDuration: String {
        let mins = totalDurationSeconds / 60
        let secs = totalDurationSeconds % 60
        return secs == 0 ? "\(mins)m" : "\(mins)m \(secs)s"
    }
}
