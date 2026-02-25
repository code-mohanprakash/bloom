import Foundation
import SwiftData

@Model
final class Affirmation {
    @Attribute(.unique) var id: UUID
    var date: Date
    var text: String
    var gratitudeEntry: String?
    var isFavourited: Bool

    init(date: Date, text: String) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.isFavourited = false
    }
}
