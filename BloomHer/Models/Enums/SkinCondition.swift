import Foundation

/// Represents the skin condition a user observes, which can correlate with cycle phase.
enum SkinCondition: String, Codable, CaseIterable, Hashable {
    case clear
    case oily
    case dry
    case acne
    case glowing

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .clear:   return "Clear"
        case .oily:    return "Oily"
        case .dry:     return "Dry"
        case .acne:    return "Acne"
        case .glowing: return "Glowing"
        }
    }

    /// A custom asset name that represents this skin condition.
    var icon: String {
        switch self {
        case .clear:   return "checkmark-circle"
        case .oily:    return "drop"
        case .dry:     return "breathing"
        case .acne:    return "target"
        case .glowing: return "sparkles"
        }
    }
}
