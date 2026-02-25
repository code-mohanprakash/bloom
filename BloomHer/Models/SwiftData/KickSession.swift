import Foundation
import SwiftData

@Model
final class KickSession {
    @Attribute(.unique) var id: UUID
    var pregnancy: PregnancyProfile?
    var startTime: Date
    var endTime: Date?
    var kickCount: Int
    var notes: String?

    var durationMinutes: Int {
        guard let end = endTime else {
            return Int(Date().timeIntervalSince(startTime) / 60)
        }
        return Int(end.timeIntervalSince(startTime) / 60)
    }

    var isComplete: Bool { endTime != nil }

    init(pregnancy: PregnancyProfile? = nil) {
        self.id = UUID()
        self.pregnancy = pregnancy
        self.startTime = Date()
        self.kickCount = 0
    }
}
