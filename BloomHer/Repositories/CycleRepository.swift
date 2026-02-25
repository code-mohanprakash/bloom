import Foundation
import SwiftData

// MARK: - CycleRepository

/// Concrete SwiftData implementation of `CycleRepositoryProtocol`.
///
/// All mutations go through the injected `ModelContext`.  The context is owned
/// by the caller (typically a view-model or `AppDependencies`) so that save
/// timing remains under caller control.  Individual methods call `context.insert`
/// for new objects; the caller is responsible for calling `try context.save()` at
/// an appropriate transaction boundary.
final class CycleRepository: CycleRepositoryProtocol {

    // MARK: Properties

    private let context: ModelContext

    // MARK: Init

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - CycleEntry

    func fetchAllCycles() -> [CycleEntry] {
        let descriptor = FetchDescriptor<CycleEntry>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchRecentCycles(count: Int) -> [CycleEntry] {
        var descriptor = FetchDescriptor<CycleEntry>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = count
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchCycle(for date: Date) -> CycleEntry? {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
            return nil
        }
        let predicate = #Predicate<CycleEntry> { cycle in
            cycle.startDate >= dayStart && cycle.startDate < dayEnd
        }
        var descriptor = FetchDescriptor<CycleEntry>(predicate: predicate)
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func fetchActiveCycle() -> CycleEntry? {
        // The "active" cycle is the most-recent confirmed entry.
        var descriptor = FetchDescriptor<CycleEntry>(
            predicate: #Predicate<CycleEntry> { $0.isConfirmed == true },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func saveCycle(_ cycle: CycleEntry) {
        // SwiftData tracks inserted objects automatically; insert is idempotent
        // for objects already in the context.
        if cycle.modelContext == nil {
            context.insert(cycle)
        }
        try? context.save()
    }

    func deleteCycle(_ cycle: CycleEntry) {
        context.delete(cycle)
        try? context.save()
    }

    // MARK: - DailyLog

    func fetchDailyLog(for date: Date) -> DailyLog? {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
            return nil
        }
        let predicate = #Predicate<DailyLog> { log in
            log.date >= dayStart && log.date < dayEnd
        }
        var descriptor = FetchDescriptor<DailyLog>(predicate: predicate)
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func fetchOrCreateDailyLog(for date: Date) -> DailyLog {
        if let existing = fetchDailyLog(for: date) {
            return existing
        }
        let newLog = DailyLog(date: date)
        context.insert(newLog)
        try? context.save()
        return newLog
    }

    func saveDailyLog(_ log: DailyLog) {
        if log.modelContext == nil {
            context.insert(log)
        }
        try? context.save()
    }

    func fetchDailyLogs(from start: Date, to end: Date) -> [DailyLog] {
        let rangeStart = Calendar.current.startOfDay(for: start)
        guard let rangeEnd = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: end)) else {
            return []
        }
        let predicate = #Predicate<DailyLog> { log in
            log.date >= rangeStart && log.date < rangeEnd
        }
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
