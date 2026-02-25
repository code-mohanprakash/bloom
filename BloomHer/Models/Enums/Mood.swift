import Foundation

/// Represents the emotional or energy states a user can log throughout their cycle.
enum Mood: String, Codable, CaseIterable, Hashable {
    case happy
    case calm
    case anxious
    case irritable
    case sad
    case angry
    case moodSwings
    case crying
    case energetic
    case tired

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .happy:      return "Happy"
        case .calm:       return "Calm"
        case .anxious:    return "Anxious"
        case .irritable:  return "Irritable"
        case .sad:        return "Sad"
        case .angry:      return "Angry"
        case .moodSwings: return "Mood Swings"
        case .crying:     return "Crying"
        case .energetic:  return "Energetic"
        case .tired:      return "Tired"
        }
    }

    /// An actual emoji character that represents this mood visually.
    var emoji: String {
        switch self {
        case .happy:      return "😊"
        case .calm:       return "😌"
        case .anxious:    return "😰"
        case .irritable:  return "😤"
        case .sad:        return "😢"
        case .angry:      return "😠"
        case .moodSwings: return "🌪️"
        case .crying:     return "😭"
        case .energetic:  return "⚡️"
        case .tired:      return "😴"
        }
    }

    /// A custom asset name that represents this mood for use in icon-based UI elements.
    var icon: String {
        switch self {
        case .happy:      return "sparkles"
        case .calm:       return "leaf"
        case .anxious:    return "pulse"
        case .irritable:  return "bolt"
        case .sad:        return "drop"
        case .angry:      return "flame"
        case .moodSwings: return "refresh"
        case .crying:     return "drop"
        case .energetic:  return "star-filled"
        case .tired:      return "moon-stars"
        }
    }
}
