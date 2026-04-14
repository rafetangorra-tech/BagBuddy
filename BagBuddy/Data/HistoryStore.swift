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
}
