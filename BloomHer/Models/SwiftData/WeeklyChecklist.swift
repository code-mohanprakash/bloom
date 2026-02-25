import Foundation
import SwiftData

struct ChecklistItem: Codable, Hashable, Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var category: String?

    init(title: String, category: String? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.category = category
    }
}

@Model
final class WeeklyChecklist {
    @Attribute(.unique) var id: UUID
    var pregnancy: PregnancyProfile?
    var week: Int
    var items: [ChecklistItem]

    init(week: Int) {
        self.id = UUID()
        self.week = week
        self.items = []
    }
}
