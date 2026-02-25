import Foundation
import SwiftData

@Model
final class ContractionEntry {
    @Attribute(.unique) var id: UUID
    var pregnancy: PregnancyProfile?
    var startTime: Date
    var endTime: Date?
    var notes: String?

    var durationSeconds: Int {
        guard let end = endTime else { return 0 }
        return Int(end.timeIntervalSince(startTime))
    }

    var isActive: Bool { endTime == nil }

    init(pregnancy: PregnancyProfile? = nil) {
        self.id = UUID()
        self.pregnancy = pregnancy
        self.startTime = Date()
    }
}
