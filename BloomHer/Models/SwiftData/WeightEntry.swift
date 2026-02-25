import Foundation
import SwiftData

@Model
final class WeightEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var weightKg: Double
    var pregnancy: PregnancyProfile?

    init(date: Date, weightKg: Double) {
        self.id = UUID()
        self.date = date
        self.weightKg = weightKg
    }
}
