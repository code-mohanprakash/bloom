import Foundation
import SwiftData

// MARK: - WellnessRepository

/// Concrete SwiftData implementation of `WellnessRepositoryProtocol`.
///
/// Affirmation lookup uses calendar-day precision so that time-of-day
/// differences between creation and retrieval do not produce duplicates.
final class WellnessRepository: WellnessRepositoryProtocol {

    // MARK: Properties

    private let context: ModelContext

    // MARK: Init

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - WellnessRepositoryProtocol

    func fetchAffirmation(for date: Date) -> Affirmation? {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
            return nil
        }
        let predicate = #Predicate<Affirmation> { affirmation in
            affirmation.date >= dayStart && affirmation.date < dayEnd
        }
        var descriptor = FetchDescriptor<Affirmation>(predicate: predicate)
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func fetchOrCreateAffirmation(for date: Date, text: String) -> Affirmation {
        if let existing = fetchAffirmation(for: date) {
            return existing
        }
        let affirmation = Affirmation(date: Calendar.current.startOfDay(for: date), text: text)
        context.insert(affirmation)
        try? context.save()
        return affirmation
    }

    func saveAffirmation(_ affirmation: Affirmation) {
        if affirmation.modelContext == nil {
            context.insert(affirmation)
        }
        try? context.save()
    }

    func fetchFavouritedAffirmations() -> [Affirmation] {
        let predicate = #Predicate<Affirmation> { $0.isFavourited == true }
        let descriptor = FetchDescriptor<Affirmation>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
