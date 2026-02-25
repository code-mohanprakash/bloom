import Foundation
import SwiftData

// MARK: - TTCRepository

/// Concrete SwiftData implementation of `TTCRepositoryProtocol`.
///
/// Supports OPK (ovulation predictor kit) result logging and basal body
/// temperature (BBT) charting used in the Trying-To-Conceive mode.
final class TTCRepository: TTCRepositoryProtocol {

    // MARK: Properties

    private let context: ModelContext

    // MARK: Init

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - OPKResult

    func fetchOPKResults(from start: Date, to end: Date) -> [OPKResult] {
        let rangeStart = Calendar.current.startOfDay(for: start)
        guard let rangeEnd = Calendar.current.date(
            byAdding: .day, value: 1,
            to: Calendar.current.startOfDay(for: end)
        ) else { return [] }

        let predicate = #Predicate<OPKResult> { result in
            result.date >= rangeStart && result.date < rangeEnd
        }
        let descriptor = FetchDescriptor<OPKResult>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveOPKResult(_ result: OPKResult) {
        if result.modelContext == nil {
            context.insert(result)
        }
        try? context.save()
    }

    // MARK: - BBTEntry

    func fetchBBTEntries(from start: Date, to end: Date) -> [BBTEntry] {
        let rangeStart = Calendar.current.startOfDay(for: start)
        guard let rangeEnd = Calendar.current.date(
            byAdding: .day, value: 1,
            to: Calendar.current.startOfDay(for: end)
        ) else { return [] }

        let predicate = #Predicate<BBTEntry> { entry in
            entry.date >= rangeStart && entry.date < rangeEnd
        }
        let descriptor = FetchDescriptor<BBTEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveBBTEntry(_ entry: BBTEntry) {
        if entry.modelContext == nil {
            context.insert(entry)
        }
        try? context.save()
    }

    // MARK: - Positive OPK Lookup

    func fetchLatestPositiveOPK(from start: Date) -> OPKResult? {
        let rangeStart = Calendar.current.startOfDay(for: start)
        // Fetch recent records then filter enum case in-memory to avoid SwiftData
        // predicate enum-case macro limitations on some toolchains.
        let predicate = #Predicate<OPKResult> { result in
            result.date >= rangeStart
        }
        let descriptor = FetchDescriptor<OPKResult>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor))?.first(where: { $0.result == .positive })
    }
}
