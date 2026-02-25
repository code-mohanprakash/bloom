import Foundation
import SwiftData

@Model
final class PregnancyProfile {
    @Attribute(.unique) var id: UUID
    var lmpDate: Date
    var dueDate: Date
    var conceptionDate: Date?
    var ultrasoundAdjustedDate: Date?
    var isActive: Bool
    var birthPlanNotes: String?
    var babyName: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var kickSessions: [KickSession]
    @Relationship(deleteRule: .cascade) var contractions: [ContractionEntry]
    @Relationship(deleteRule: .cascade) var weightEntries: [WeightEntry]
    @Relationship(deleteRule: .cascade) var appointments: [Appointment]
    @Relationship(deleteRule: .cascade) var weeklyChecklists: [WeeklyChecklist]

    var currentWeek: Int {
        let days = Calendar.current.dateComponents([.day], from: lmpDate, to: Date()).day ?? 0
        return max(1, min(42, (days / 7) + 1))
    }

    var currentDay: Int {
        Calendar.current.dateComponents([.day], from: lmpDate, to: Date()).day ?? 0
    }

    var trimester: Int {
        switch currentWeek {
        case 1...12: return 1
        case 13...26: return 2
        default: return 3
        }
    }

    var daysUntilDue: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0)
    }

    init(lmpDate: Date) {
        self.id = UUID()
        self.lmpDate = lmpDate
        self.dueDate = Calendar.current.date(byAdding: .day, value: 280, to: lmpDate) ?? lmpDate
        self.isActive = true
        self.createdAt = Date()
        self.kickSessions = []
        self.contractions = []
        self.weightEntries = []
        self.appointments = []
        self.weeklyChecklists = []
    }
}
