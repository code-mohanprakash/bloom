import Foundation
import SwiftData

// MARK: - YogaRepository

/// Concrete SwiftData implementation of `YogaRepositoryProtocol`.
///
/// Week boundaries are calculated using ISO-8601 semantics: weeks run
/// Monday–Sunday.  This aligns with the app's activity-ring metaphor and
/// avoids Sunday-first ambiguities in some locales.
final class YogaRepository: YogaRepositoryProtocol {

    // MARK: Properties

    private let context: ModelContext

    // MARK: Init

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Fetch

    func fetchSessions(from start: Date, to end: Date) -> [YogaSession] {
        let rangeStart = Calendar.current.startOfDay(for: start)
        guard let rangeEnd = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: end)) else {
            return []
        }
        let predicate = #Predicate<YogaSession> { session in
            session.date >= rangeStart && session.date < rangeEnd
        }
        let descriptor = FetchDescriptor<YogaSession>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchRecentSessions(count: Int) -> [YogaSession] {
        var descriptor = FetchDescriptor<YogaSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = count
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveSession(_ session: YogaSession) {
        if session.modelContext == nil {
            context.insert(session)
        }
        try? context.save()
    }

    // MARK: - Aggregation

    func totalMinutesThisWeek() -> Int {
        let (weekStart, weekEnd) = currentISOWeekInterval()
        let sessions = fetchSessions(from: weekStart, to: weekEnd)
        return sessions
            .filter { $0.completed }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    // MARK: - Private Helpers

    /// Returns the Monday 00:00:00 and Sunday 23:59:59 of the ISO week
    /// that contains today.
    private func currentISOWeekInterval() -> (start: Date, end: Date) {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .current
        calendar.timeZone = .current

        let today = Date()
        // iso8601 calendar: weekday 2 = Monday
        let weekday = calendar.component(.weekday, from: today)
        // Days to subtract to reach Monday (weekday 2 in ISO calendar)
        let daysFromMonday = (weekday - 2 + 7) % 7
        let monday = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        )
        // Sunday is 6 days after Monday
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
        return (monday, sunday)
    }
}
