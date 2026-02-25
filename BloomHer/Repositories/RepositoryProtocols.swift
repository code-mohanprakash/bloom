import Foundation
import SwiftData

// MARK: - CycleRepositoryProtocol

/// Abstracts all SwiftData access for menstrual cycle entries and daily logs.
/// Consumers depend on this protocol, never on the concrete implementation,
/// enabling straightforward substitution in tests.
protocol CycleRepositoryProtocol {
    /// Returns every stored CycleEntry, sorted by startDate ascending.
    func fetchAllCycles() -> [CycleEntry]

    /// Returns the `count` most-recent CycleEntries, sorted by startDate descending.
    func fetchRecentCycles(count: Int) -> [CycleEntry]

    /// Returns the CycleEntry whose startDate falls on the same calendar day as `date`, or nil.
    func fetchCycle(for date: Date) -> CycleEntry?

    /// Returns the most-recent confirmed CycleEntry (the one that is currently active).
    func fetchActiveCycle() -> CycleEntry?

    /// Inserts or updates a CycleEntry in the persistent store.
    func saveCycle(_ cycle: CycleEntry)

    /// Removes a CycleEntry and its cascaded DailyLogs from the persistent store.
    func deleteCycle(_ cycle: CycleEntry)

    /// Returns the DailyLog whose date matches `date` (calendar-day precision), or nil.
    func fetchDailyLog(for date: Date) -> DailyLog?

    /// Returns the DailyLog for `date`, creating and inserting a new one if absent.
    func fetchOrCreateDailyLog(for date: Date) -> DailyLog

    /// Inserts or updates a DailyLog in the persistent store.
    func saveDailyLog(_ log: DailyLog)

    /// Returns all DailyLogs whose date falls within the closed interval [start, end].
    func fetchDailyLogs(from start: Date, to end: Date) -> [DailyLog]
}

// MARK: - PregnancyRepositoryProtocol

/// Abstracts all SwiftData access for pregnancy tracking data.
protocol PregnancyRepositoryProtocol {
    /// Returns the single PregnancyProfile where isActive == true, or nil.
    func fetchActivePregnancy() -> PregnancyProfile?

    /// Returns all stored PregnancyProfiles, sorted by createdAt descending.
    func fetchAllPregnancies() -> [PregnancyProfile]

    /// Inserts or updates a PregnancyProfile in the persistent store.
    func savePregnancy(_ pregnancy: PregnancyProfile)

    /// Removes a PregnancyProfile and all cascaded children from the persistent store.
    func deletePregnancy(_ pregnancy: PregnancyProfile)

    /// Returns all KickSessions belonging to `pregnancy`, sorted by startTime descending.
    func fetchKickSessions(for pregnancy: PregnancyProfile) -> [KickSession]

    /// Inserts or updates a KickSession in the persistent store.
    func saveKickSession(_ session: KickSession)

    /// Returns all ContractionEntries belonging to `pregnancy`, sorted by startTime descending.
    func fetchContractions(for pregnancy: PregnancyProfile) -> [ContractionEntry]

    /// Inserts or updates a ContractionEntry in the persistent store.
    func saveContraction(_ contraction: ContractionEntry)

    /// Returns all WeightEntries belonging to `pregnancy`, sorted by date ascending.
    func fetchWeightEntries(for pregnancy: PregnancyProfile) -> [WeightEntry]

    /// Inserts or updates a WeightEntry in the persistent store.
    func saveWeightEntry(_ entry: WeightEntry)

    /// Returns all Appointments belonging to `pregnancy`, sorted by date ascending.
    func fetchAppointments(for pregnancy: PregnancyProfile) -> [Appointment]

    /// Inserts or updates an Appointment in the persistent store.
    func saveAppointment(_ appointment: Appointment)

    /// Removes an Appointment from the persistent store.
    func deleteAppointment(_ appointment: Appointment)
}

// MARK: - YogaRepositoryProtocol

/// Abstracts all SwiftData access for yoga and movement session history.
protocol YogaRepositoryProtocol {
    /// Returns all YogaSessions with a date within the closed interval [start, end].
    func fetchSessions(from start: Date, to end: Date) -> [YogaSession]

    /// Returns the `count` most-recent YogaSessions, sorted by date descending.
    func fetchRecentSessions(count: Int) -> [YogaSession]

    /// Inserts or updates a YogaSession in the persistent store.
    func saveSession(_ session: YogaSession)

    /// Calculates the total duration in minutes for all completed sessions
    /// that fall within the ISO week (Monday–Sunday) containing today.
    func totalMinutesThisWeek() -> Int
}

// MARK: - WellnessRepositoryProtocol

/// Abstracts all SwiftData access for daily affirmations and gratitude entries.
protocol WellnessRepositoryProtocol {
    /// Returns the Affirmation whose date matches `date` (calendar-day precision), or nil.
    func fetchAffirmation(for date: Date) -> Affirmation?

    /// Returns the Affirmation for `date`, creating one with `text` if absent.
    func fetchOrCreateAffirmation(for date: Date, text: String) -> Affirmation

    /// Inserts or updates an Affirmation in the persistent store.
    func saveAffirmation(_ affirmation: Affirmation)

    /// Returns all Affirmations where isFavourited == true, sorted by date descending.
    func fetchFavouritedAffirmations() -> [Affirmation]
}

// MARK: - TTCRepositoryProtocol

/// Abstracts all SwiftData access for Trying-To-Conceive fertility data.
protocol TTCRepositoryProtocol {
    /// Returns all OPKResults with a date within the closed interval [start, end].
    func fetchOPKResults(from start: Date, to end: Date) -> [OPKResult]

    /// Inserts or updates an OPKResult in the persistent store.
    func saveOPKResult(_ result: OPKResult)

    /// Returns all BBTEntries with a date within the closed interval [start, end].
    func fetchBBTEntries(from start: Date, to end: Date) -> [BBTEntry]

    /// Inserts or updates a BBTEntry in the persistent store.
    func saveBBTEntry(_ entry: BBTEntry)

    /// Returns the most recent OPKResult with result == .positive on or after `start`, or nil.
    func fetchLatestPositiveOPK(from start: Date) -> OPKResult?
}
