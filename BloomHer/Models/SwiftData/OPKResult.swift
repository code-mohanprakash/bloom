import Foundation
import SwiftData

@Model
final class OPKResult {
    @Attribute(.unique) var id: UUID
    var date: Date
    var result: OPKLevel

    init(date: Date, result: OPKLevel) {
        self.id = UUID()
        self.date = date
        self.result = result
    }
}
