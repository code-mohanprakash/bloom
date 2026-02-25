import Foundation
import SwiftData

@Model
final class YogaSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var routineId: String
    var routineName: String
    var durationMinutes: Int
    var category: ExerciseCategory
    var completed: Bool

    init(routineId: String, routineName: String, category: ExerciseCategory, durationMinutes: Int) {
        self.id = UUID()
        self.date = Date()
        self.routineId = routineId
        self.routineName = routineName
        self.durationMinutes = durationMinutes
        self.category = category
        self.completed = false
    }
}
