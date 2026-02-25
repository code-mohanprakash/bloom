import Foundation

/// Represents sexual activity and libido states a user can log.
enum SexualActivity: String, Codable, CaseIterable, Hashable {
    case protectedSex
    case unprotectedSex
    case highLibido
    case lowLibido

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .protectedSex:   return "Protected Sex"
        case .unprotectedSex: return "Unprotected Sex"
        case .highLibido:     return "High Libido"
        case .lowLibido:      return "Low Libido"
        }
    }

    /// A custom asset name that represents this activity or libido state.
    var icon: String {
        switch self {
        case .protectedSex:   return "lock-shield"
        case .unprotectedSex: return "heart-filled"
        case .highLibido:     return "flame"
        case .lowLibido:      return "flame"
        }
    }
}
