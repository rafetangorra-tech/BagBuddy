import HealthKit
import Foundation

/// Handles all HealthKit interactions for Bag Buddy.
/// Logs each completed session as an HKWorkout of type .boxing or .kickboxing.
@MainActor
final class HealthKitManager {
    static let shared = HealthKitManager()

    private let store = HKHealthStore()
    private var workoutStartDate: Date?

    private init() {}

    // MARK: - Authorization

    /// Requests HealthKit write permission. Safe to call multiple times.
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let types: Set<HKSampleType> = [
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned)
        ]

        try? await store.requestAuthorization(toShare: types, read: [])
    }

    // MARK: - Workout Lifecycle

    func workoutDidStart() {
        workoutStartDate = Date()
    }

    /// Saves the completed workout to HealthKit.
    /// - Parameters:
    ///   - discipline: Boxing or Muay Thai — maps to the correct HKWorkoutActivityType
    ///   - roundDuration: Seconds per round (used to estimate calories)
    ///   - numberOfRounds: Total rounds completed
    func workoutDidEnd(discipline: Discipline, roundDuration: Int, numberOfRounds: Int) async {
        guard HKHealthStore.isHealthDataAvailable(),
              let startDate = workoutStartDate else { return }

        workoutStartDate = nil
        let endDate = Date()

        let activityType: HKWorkoutActivityType = discipline == .muayThai ? .kickboxing : .boxing

        // Rough calorie estimate: ~10 cal/min for boxing, ~11 for Muay Thai
        let calPerMin: Double = discipline == .muayThai ? 11 : 10
        let totalMinutes = Double(roundDuration * numberOfRounds) / 60.0
        let calories = calPerMin * totalMinutes
        let energyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: calories)

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = .indoor

        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())

        do {
            try await builder.beginCollection(at: startDate)

            let energySample = HKQuantitySample(
                type: HKQuantityType(.activeEnergyBurned),
                quantity: energyBurned,
                start: startDate,
                end: endDate
            )
            try await builder.addSamples([energySample])
            try await builder.endCollection(at: endDate)
            _ = try await builder.finishWorkout()
        } catch {
            print("[HealthKit] Failed to save workout: \(error)")
        }
    }
}
