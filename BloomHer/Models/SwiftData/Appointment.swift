import Foundation
import SwiftData

@Model
final class Appointment {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var location: String?
    var notes: String?
    var reminderMinutesBefore: Int?
    var pregnancy: PregnancyProfile?
    var isCompleted: Bool

    init(title: String, date: Date) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.isCompleted = false
    }
}
