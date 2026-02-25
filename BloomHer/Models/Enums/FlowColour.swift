import SwiftUI

/// Represents the observed colour of menstrual flow, which can indicate health status.
enum FlowColour: String, Codable, CaseIterable, Hashable {
    case pink
    case red
    case darkRed
    case brown
    case black

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .pink:    return "Pink"
        case .red:     return "Red"
        case .darkRed: return "Dark Red"
        case .brown:   return "Brown"
        case .black:   return "Black"
        }
    }

    /// Custom asset icon name for this colour option.
    var icon: String {
        return "drop"
    }

    /// The SwiftUI `Color` that visually represents this flow colour in the UI.
    /// Hex values are used directly to avoid dependency on a shared colour asset.
    var color: Color {
        switch self {
        case .pink:    return Color(hex: "#FFB6C1")
        case .red:     return Color(hex: "#DC143C")
        case .darkRed: return Color(hex: "#8B0000")
        case .brown:   return Color(hex: "#8B4513")
        case .black:   return Color(hex: "#1C1C1E")
        }
    }
}
