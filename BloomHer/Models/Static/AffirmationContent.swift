import Foundation

struct AffirmationContent: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let phase: CyclePhase?           // nil = universal
    let isPregnancy: Bool
    let isTTC: Bool
    let isPostpartum: Bool
    let category: AffirmationCategory

    init(
        id: String = UUID().uuidString,
        text: String,
        phase: CyclePhase? = nil,
        isPregnancy: Bool = false,
        isTTC: Bool = false,
        isPostpartum: Bool = false,
        category: AffirmationCategory = .general
    ) {
        self.id = id
        self.text = text
        self.phase = phase
        self.isPregnancy = isPregnancy
        self.isTTC = isTTC
        self.isPostpartum = isPostpartum
        self.category = category
    }
}

enum AffirmationCategory: String, Codable, CaseIterable, Hashable {
    case general, body, strength, rest, growth, love, courage

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .general:  return "sparkles"
        case .body:     return "figure-stand"
        case .strength: return "bolt"
        case .rest:     return "moon-stars"
        case .growth:   return "leaf"
        case .love:     return "heart"
        case .courage:  return "flame"
        }
    }
}
