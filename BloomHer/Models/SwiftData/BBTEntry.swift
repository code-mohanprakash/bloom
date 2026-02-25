import Foundation
import SwiftData

@Model
final class BBTEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var temperatureCelsius: Double

    init(date: Date, temperatureCelsius: Double) {
        self.id = UUID()
        self.date = date
        self.temperatureCelsius = temperatureCelsius
    }
}
