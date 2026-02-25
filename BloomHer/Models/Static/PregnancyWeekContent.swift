import Foundation

struct PregnancyWeekContent: Identifiable, Codable, Hashable {
    var id: Int { week }
    let week: Int
    let fruitComparison: String       // e.g., "Lime"
    let fruitEmoji: String            // e.g., "🍋"
    let babySizeCm: Double?           // crown-to-rump or crown-to-heel
    let babyWeightGrams: Double?
    let babyDevelopment: [String]     // bullet points about baby this week
    let motherChanges: [String]       // bullet points about mother's body
    let tips: [String]                // practical tips
    let warningSignsToWatch: [String] // when to call doctor
    let source: String                // e.g., "NHS", "ACOG"

    var trimester: Int {
        switch week {
        case 1...12: return 1
        case 13...26: return 2
        default: return 3
        }
    }
}

extension PregnancyWeekContent {
    var babyLength: String {
        guard let babySizeCm else { return "—" }
        return String(format: "~%.1f cm", babySizeCm)
    }

    var babyWeight: String {
        guard let babyWeightGrams else { return "—" }
        if babyWeightGrams >= 1000 {
            return String(format: "~%.1f kg", babyWeightGrams / 1000)
        }
        return String(format: "~%.0f g", babyWeightGrams)
    }

    var developmentHighlights: [String] {
        babyDevelopment
    }

    var bodyChanges: [String] {
        motherChanges
    }
}
