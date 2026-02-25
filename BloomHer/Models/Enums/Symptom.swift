import Foundation

/// Represents physical symptoms a user may experience across their cycle.
enum Symptom: String, Codable, CaseIterable, Hashable {
    case headache
    case backPain
    case breastTenderness
    case bloating
    case jointPain
    case pelvicPain
    case nausea
    case diarrhoea
    case constipation
    case acne
    case insomnia
    case hotFlush
    case dizziness

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .headache:          return "Headache"
        case .backPain:          return "Back Pain"
        case .breastTenderness:  return "Breast Tenderness"
        case .bloating:          return "Bloating"
        case .jointPain:         return "Joint Pain"
        case .pelvicPain:        return "Pelvic Pain"
        case .nausea:            return "Nausea"
        case .diarrhoea:         return "Diarrhoea"
        case .constipation:      return "Constipation"
        case .acne:              return "Acne"
        case .insomnia:          return "Insomnia"
        case .hotFlush:          return "Hot Flush"
        case .dizziness:         return "Dizziness"
        }
    }

    /// A custom asset name that visually represents this symptom.
    var icon: String {
        switch self {
        case .headache:          return "pulse"
        case .backPain:          return "figure-stand"
        case .breastTenderness:  return "heart-filled"
        case .bloating:          return "drop"
        case .jointPain:         return "bolt"
        case .pelvicPain:        return "sparkles"
        case .nausea:            return "breathing"
        case .diarrhoea:         return "drop"
        case .constipation:      return "pause"
        case .acne:              return "target"
        case .insomnia:          return "moon-stars"
        case .hotFlush:          return "thermometer"
        case .dizziness:         return "refresh"
        }
    }
}
