import Foundation

/// Loads all combos from the bundled combos.json and provides
/// filtered pools for each discipline / workout mode.
struct ComboService {

    static let shared = ComboService()

    private let allCombos: [Combo]

    private init() {
        guard
            let url  = Bundle.main.url(forResource: "combos", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let db   = try? JSONDecoder().decode(ComboDB.self, from: data)
        else {
            assertionFailure("combos.json missing or invalid")
            allCombos = []
            return
        }
        allCombos = db.combos
    }

    /// Returns combos eligible for random call-out in No Defense or With Defense mode.
    /// Only combos with recorded audio are returned.
    func callOutPool(discipline: Discipline, mode: WorkoutMode) -> [Combo] {
        allCombos.filter {
            $0.discipline == discipline &&
            $0.mode == mode &&
            $0.hasAudio
        }
    }

    /// Returns combos for Drill mode.
    /// Drill combos are always included regardless of hasAudio — the app shows
    /// the combination on screen and plays audio only if available.
    func drillPool(discipline: Discipline) -> [Combo] {
        allCombos.filter {
            $0.discipline == discipline &&
            $0.mode == .drill
        }
    }
}
