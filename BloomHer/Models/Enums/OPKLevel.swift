import SwiftUI

/// Represents the result level of an Ovulation Predictor Kit (OPK) test strip.
enum OPKLevel: String, Codable, CaseIterable, Hashable {
    case negative
    case faint
    case positive

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .negative: return "Negative"
        case .faint:    return "Faint"
        case .positive: return "Positive"
        }
    }

    /// A custom asset name that visually represents the OPK result.
    var icon: String {
        switch self {
        case .negative: return "minus-circle"
        case .faint:    return "target"
        case .positive: return "plus-circle"
        }
    }

    /// The SwiftUI `Color` associated with this OPK result level.
    var color: Color {
        switch self {
        case .negative: return Color(hex: "#A9A9A9")
        case .faint:    return Color(hex: "#F9D5A7")
        case .positive: return Color(hex: "#A8D5BA")
        }
    }
}
