import Foundation

/// Represents the intensity of menstrual flow, ranging from spotting to very heavy.
enum FlowLevel: String, Codable, CaseIterable, Hashable {
    case spotting
    case light
    case medium
    case heavy
    case veryHeavy

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .spotting:  return "Spotting"
        case .light:     return "Light"
        case .medium:    return "Medium"
        case .heavy:     return "Heavy"
        case .veryHeavy: return "Very Heavy"
        }
    }

    /// A custom asset name representing flow intensity.
    var icon: String {
        switch self {
        case .spotting:  return "drop"
        case .light:     return "drop"
        case .medium:    return "drop"
        case .heavy:     return "drop"
        case .veryHeavy: return "drop"
        }
    }

    /// The number of filled dots (1–5) used to render a visual intensity indicator.
    var dotCount: Int {
        switch self {
        case .spotting:  return 1
        case .light:     return 2
        case .medium:    return 3
        case .heavy:     return 4
        case .veryHeavy: return 5
        }
    }
}
