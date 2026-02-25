import Foundation
import SwiftData

@Model
final class CycleEntry {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var predictedStartDate: Date?
    var cycleLengthDays: Int?
    var isConfirmed: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \DailyLog.cycleEntry)
    var dailyLogs: [DailyLog]

    init(startDate: Date, isConfirmed: Bool = true) {
        self.id = UUID()
        self.startDate = startDate
        self.isConfirmed = isConfirmed
        self.createdAt = Date()
        self.dailyLogs = []
    }
}
