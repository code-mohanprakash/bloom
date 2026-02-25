import Foundation
import HealthKit

// MARK: - Protocol

protocol HealthKitServiceProtocol {
    /// True when HealthKit is available on this device (not available on iPad without entitlement,
    /// and never available on macOS Catalyst without the HealthKit entitlement).
    var isAvailable: Bool { get }

    /// True when the user has granted at least share + read authorisation for menstrual flow.
    var isAuthorized: Bool { get }

    /// Presents the system HealthKit authorisation sheet and awaits the user's decision.
    func requestAuthorization() async throws

    /// Writes a menstrual flow data point to HealthKit.
    func writeMenstrualFlow(date: Date, flow: FlowLevel) async throws

    /// Reads menstrual flow samples within the given date range.
    func readMenstrualFlow(from start: Date, to end: Date) async throws -> [(date: Date, flow: HKCategoryValueMenstrualFlow)]

    /// Writes a basal body temperature sample to HealthKit.
    func writeBasalBodyTemp(date: Date, tempCelsius: Double) async throws

    /// Reads sleep analysis samples within the given date range.
    /// Each tuple represents one sleep interval with its computed hours.
    func readSleepAnalysis(from start: Date, to end: Date) async throws -> [(start: Date, end: Date, hours: Double)]

    /// Writes a yoga / mindfulness workout to HealthKit.
    func writeWorkout(duration: TimeInterval, type: HKWorkoutActivityType) async throws
}

// MARK: - HealthKitService

/// Concrete implementation backed by `HKHealthStore`.
///
/// All HealthKit work is performed off the main actor via `async` throws wrappers
/// around the callback-based HealthKit API.  The class itself is not actor-isolated
/// so it can be called from any context.
final class HealthKitService: HealthKitServiceProtocol {

    // MARK: - Properties

    private let store: HKHealthStore

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorisation state

    var isAuthorized: Bool {
        guard isAvailable else { return false }
        let status = store.authorizationStatus(for: HKCategoryType(.menstrualFlow))
        return status == .sharingAuthorized
    }

    // MARK: - Types We Request

    private var shareTypes: Set<HKSampleType> {
        var types: Set<HKSampleType> = []

        // Menstrual flow (write)
        if let t = HKSampleType.categoryType(forIdentifier: .menstrualFlow) { types.insert(t) }
        // Basal body temperature (write)
        if let t = HKSampleType.quantityType(forIdentifier: .basalBodyTemperature) { types.insert(t) }
        // Workout (write)
        types.insert(HKObjectType.workoutType())

        return types
    }

    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        if let t = HKObjectType.categoryType(forIdentifier: .menstrualFlow) { types.insert(t) }
        if let t = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(t) }
        if let t = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature) { types.insert(t) }

        return types
    }

    // MARK: - Init

    init() {
        self.store = HKHealthStore()
    }

    // MARK: - HealthKitServiceProtocol

    func requestAuthorization() async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }
        try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func writeMenstrualFlow(date: Date, flow: FlowLevel) async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }

        guard let type = HKCategoryType.categoryType(forIdentifier: .menstrualFlow) else {
            throw HealthKitError.typeUnavailable
        }

        let hkFlow = flow.hkMenstrualFlow
        let metadata: [String: Any] = [HKMetadataKeyMenstrualCycleStart: false]
        let sample  = HKCategorySample(
            type:      type,
            value:     hkFlow.rawValue,
            start:     date,
            end:       date.addingTimeInterval(60),
            metadata:  metadata
        )

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { _, error in
                if let error { continuation.resume(throwing: error) }
                else         { continuation.resume() }
            }
        }
    }

    func readMenstrualFlow(
        from start: Date,
        to end: Date
    ) async throws -> [(date: Date, flow: HKCategoryValueMenstrualFlow)] {
        guard isAvailable else { throw HealthKitError.notAvailable }

        guard let type = HKCategoryType.categoryType(forIdentifier: .menstrualFlow) else {
            throw HealthKitError.typeUnavailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictEndDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType:   type,
                predicate:    predicate,
                limit:        HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let results: [(date: Date, flow: HKCategoryValueMenstrualFlow)] = (samples as? [HKCategorySample] ?? [])
                    .compactMap { sample in
                        guard let flow = HKCategoryValueMenstrualFlow(rawValue: sample.value) else { return nil }
                        return (date: sample.startDate, flow: flow)
                    }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }

    func writeBasalBodyTemp(date: Date, tempCelsius: Double) async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }

        guard let type = HKQuantityType.quantityType(forIdentifier: .basalBodyTemperature) else {
            throw HealthKitError.typeUnavailable
        }

        let quantity = HKQuantity(unit: HKUnit.degreeCelsius(), doubleValue: tempCelsius)
        let sample   = HKQuantitySample(type: type, quantity: quantity, start: date, end: date.addingTimeInterval(60))

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { _, error in
                if let error { continuation.resume(throwing: error) }
                else         { continuation.resume() }
            }
        }
    }

    func readSleepAnalysis(
        from start: Date,
        to end: Date
    ) async throws -> [(start: Date, end: Date, hours: Double)] {
        guard isAvailable else { throw HealthKitError.notAvailable }

        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.typeUnavailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictEndDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType:      type,
                predicate:       predicate,
                limit:           HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let results: [(start: Date, end: Date, hours: Double)] = (samples as? [HKCategorySample] ?? [])
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
                           || $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue
                           || $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue
                           || $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
                    .map { sample in
                        let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                        return (start: sample.startDate, end: sample.endDate, hours: hours)
                    }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }

    func writeWorkout(duration: TimeInterval, type: HKWorkoutActivityType) async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }

        let end   = Date()
        let start = end.addingTimeInterval(-duration)

        let workout = HKWorkout(
            activityType:  type,
            start:         start,
            end:           end,
            duration:      duration,
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata:      [HKMetadataKeyWorkoutBrandName: "BloomHer"]
        )

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(workout) { _, error in
                if let error { continuation.resume(throwing: error) }
                else         { continuation.resume() }
            }
        }
    }
}

// MARK: - HealthKitError

enum HealthKitError: LocalizedError {
    case notAvailable
    case typeUnavailable
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device."
        case .typeUnavailable:
            return "The requested HealthKit data type is not available."
        case .authorizationDenied:
            return "HealthKit access has been denied. Please enable it in Settings > Privacy > Health."
        }
    }
}

// MARK: - FlowLevel + HealthKit

private extension FlowLevel {
    /// Maps BloomHer's `FlowLevel` to the corresponding HealthKit enum value.
    var hkMenstrualFlow: HKCategoryValueMenstrualFlow {
        switch self {
        case .spotting:  return .light
        case .light:     return .light
        case .medium:    return .medium
        case .heavy:     return .heavy
        case .veryHeavy: return .heavy
        }
    }
}

