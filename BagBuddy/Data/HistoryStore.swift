import Foundation

/// Persists and retrieves WorkoutRecords using UserDefaults.
final class HistoryStore {
    static let shared = HistoryStore()
    private let key = "workoutHistory"
    private init() {}

    var records: [WorkoutRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WorkoutRecord].self, from: data)
        else { return [] }
        return decoded
    }

    func save(_ record: WorkoutRecord) {
        var all = records
        all.insert(record, at: 0)
        if let encoded = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Current training streak in days.
    /// A streak is consecutive calendar days (ending today or yesterday) with at least one session.
    var currentStreak: Int {
        let calendar = Calendar.current
        let allDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        guard !allDays.isEmpty else { return 0 }

        var streak = 0
        var checking = calendar.startOfDay(for: Date())

        // If nothing today, check if yesterday keeps the streak alive
        if !allDays.contains(checking) {
            checking = calendar.date(byAdding: .day, value: -1, to: checking)!
            if !allDays.contains(checking) { return 0 }
        }

        while allDays.contains(checking) {
            streak += 1
            checking = calendar.date(byAdding: .day, value: -1, to: checking)!
        }
        return streak
    }
}
