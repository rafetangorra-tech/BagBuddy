import Foundation

final class PresetStore: ObservableObject {
    static let shared = PresetStore()
    private let key = "workoutPresets"

    @Published private(set) var presets: [WorkoutPreset] = []

    private init() { load() }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WorkoutPreset].self, from: data)
        else { return }
        presets = decoded
    }

    func save(_ preset: WorkoutPreset) {
        presets.removeAll { $0.id == preset.id }
        presets.insert(preset, at: 0)
        persist()
    }

    func delete(id: UUID) {
        presets.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
