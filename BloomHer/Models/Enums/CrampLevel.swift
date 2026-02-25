import Foundation

/// Represents the severity of menstrual cramping experienced by the user.
enum CrampLevel: String, Codable, CaseIterable, Hashable {
    case mild
    case moderate
    case severe
    case debilitating

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .mild:         return "Mild"
        case .moderate:     return "Moderate"
        case .severe:       return "Severe"
        case .debilitating: return "Debilitating"
        }
    }

    /// A custom asset name conveying pain severity.
    var icon: String {
        switch self {
        case .mild:         return "face-smiling"
        case .moderate:     return "face-smiling"
        case .severe:       return "error-circle"
        case .debilitating: return "warning"
        }
    }

    /// A numeric value (1–4) that can be used for sorting, charting, or scoring.
    var numericValue: Int {
        switch self {
        case .mild:         return 1
        case .moderate:     return 2
        case .severe:       return 3
        case .debilitating: return 4
        }
    }
}
