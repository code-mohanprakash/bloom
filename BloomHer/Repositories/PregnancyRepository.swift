import Foundation
import SwiftData

// MARK: - PregnancyRepository

/// Concrete SwiftData implementation of `PregnancyRepositoryProtocol`.
///
/// Children (kick sessions, contractions, weight entries, appointments) are
/// fetched by filtering on the relationship UUID rather than by a back-reference
/// predicate, which keeps the `#Predicate` macro usage straightforward with
/// SwiftData's current macro-based query API.
final class PregnancyRepository: PregnancyRepositoryProtocol {

    // MARK: Properties

    private let context: ModelContext

    // MARK: Init

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - PregnancyProfile

    func fetchActivePregnancy() -> PregnancyProfile? {
        let predicate = #Predicate<PregnancyProfile> { $0.isActive == true }
        var descriptor = FetchDescriptor<PregnancyProfile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func fetchAllPregnancies() -> [PregnancyProfile] {
        let descriptor = FetchDescriptor<PregnancyProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func savePregnancy(_ pregnancy: PregnancyProfile) {
        if pregnancy.modelContext == nil {
            context.insert(pregnancy)
        }
        try? context.save()
    }

    func deletePregnancy(_ pregnancy: PregnancyProfile) {
        context.delete(pregnancy)
        try? context.save()
    }

    // MARK: - KickSession

    func fetchKickSessions(for pregnancy: PregnancyProfile) -> [KickSession] {
        let pregnancyID = pregnancy.id
        let predicate = #Predicate<KickSession> { session in
            session.pregnancy?.id == pregnancyID
        }
        let descriptor = FetchDescriptor<KickSession>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveKickSession(_ session: KickSession) {
        if session.modelContext == nil {
            context.insert(session)
        }
        try? context.save()
    }

    // MARK: - ContractionEntry

    func fetchContractions(for pregnancy: PregnancyProfile) -> [ContractionEntry] {
        let pregnancyID = pregnancy.id
        let predicate = #Predicate<ContractionEntry> { contraction in
            contraction.pregnancy?.id == pregnancyID
        }
        let descriptor = FetchDescriptor<ContractionEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveContraction(_ contraction: ContractionEntry) {
        if contraction.modelContext == nil {
            context.insert(contraction)
        }
        try? context.save()
    }

    // MARK: - WeightEntry

    func fetchWeightEntries(for pregnancy: PregnancyProfile) -> [WeightEntry] {
        let pregnancyID = pregnancy.id
        let predicate = #Predicate<WeightEntry> { entry in
            entry.pregnancy?.id == pregnancyID
        }
        let descriptor = FetchDescriptor<WeightEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveWeightEntry(_ entry: WeightEntry) {
        if entry.modelContext == nil {
            context.insert(entry)
        }
        try? context.save()
    }

    // MARK: - Appointment

    func fetchAppointments(for pregnancy: PregnancyProfile) -> [Appointment] {
        let pregnancyID = pregnancy.id
        let predicate = #Predicate<Appointment> { appointment in
            appointment.pregnancy?.id == pregnancyID
        }
        let descriptor = FetchDescriptor<Appointment>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveAppointment(_ appointment: Appointment) {
        if appointment.modelContext == nil {
            context.insert(appointment)
        }
        try? context.save()
    }

    func deleteAppointment(_ appointment: Appointment) {
        context.delete(appointment)
        try? context.save()
    }
}
