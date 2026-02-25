import Foundation

/// Represents the type of cervical discharge observed, which is a key fertility indicator.
enum DischargeType: String, Codable, CaseIterable, Hashable {
    case none
    case sticky
    case creamy
    case watery
    case eggWhite
    case spotting

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .none:     return "None"
        case .sticky:   return "Sticky"
        case .creamy:   return "Creamy"
        case .watery:   return "Watery"
        case .eggWhite: return "Egg White"
        case .spotting: return "Spotting"
        }
    }

    /// A custom asset name that visually represents this discharge type.
    var icon: String {
        switch self {
        case .none:     return "minus-circle"
        case .sticky:   return "drop"
        case .creamy:   return "drop"
        case .watery:   return "drop"
        case .eggWhite: return "drop"
        case .spotting: return "drop"
        }
    }
}
