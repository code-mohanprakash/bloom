import Foundation
import SwiftData

@Model
final class PartnerShare {
    @Attribute(.unique) var id: UUID
    var shareCode: String
    var partnerName: String?
    var isActive: Bool
    var sharesMood: Bool
    var sharesPhase: Bool
    var sharesPregnancyWeek: Bool
    var createdAt: Date

    init(shareCode: String) {
        self.id = UUID()
        self.shareCode = shareCode
        self.isActive = true
        self.sharesMood = true
        self.sharesPhase = true
        self.sharesPregnancyWeek = true
        self.createdAt = Date()
    }
}
