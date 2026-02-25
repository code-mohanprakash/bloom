import Foundation

struct SelfCareItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let phase: CyclePhase?          // nil = universal
    let isPregnancy: Bool
    let category: SelfCareCategory
    var isCompleted: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        icon: String,
        phase: CyclePhase? = nil,
        isPregnancy: Bool = false,
        category: SelfCareCategory = .relaxation,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.phase = phase
        self.isPregnancy = isPregnancy
        self.category = category
        self.isCompleted = isCompleted
    }
}

enum SelfCareCategory: String, Codable, CaseIterable, Hashable {
    case relaxation, movement, nutrition, mindfulness, social, creative

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .relaxation:  return "selfcare-relaxation"
        case .movement:    return "selfcare-movement"
        case .nutrition:   return "nutrition"
        case .mindfulness: return "selfcare-mindfulness"
        case .social:      return "selfcare-social"
        case .creative:    return "selfcare-creative"
        }
    }

    var customImage: String? {
        switch self {
        case .relaxation:  return "selfcare-relaxation"
        case .movement:    return "selfcare-movement"
        case .nutrition:   return "nutrition"
        case .mindfulness: return "selfcare-mindfulness"
        case .social:      return "selfcare-social"
        case .creative:    return "selfcare-creative"
        }
    }
}

struct BreathingPattern: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let inhaleSeconds: Int
    let holdSeconds: Int
    let exhaleSeconds: Int
    let holdAfterExhaleSeconds: Int
    let rounds: Int

    var totalCycleSeconds: Int {
        inhaleSeconds + holdSeconds + exhaleSeconds + holdAfterExhaleSeconds
    }

    static let boxBreathing = BreathingPattern(
        id: "box",
        name: "Box Breathing",
        description: "Equal counts for calm focus",
        inhaleSeconds: 4,
        holdSeconds: 4,
        exhaleSeconds: 4,
        holdAfterExhaleSeconds: 4,
        rounds: 4
    )

    static let fourSevenEight = BreathingPattern(
        id: "478",
        name: "4-7-8 Breathing",
        description: "Relaxation technique for sleep and anxiety",
        inhaleSeconds: 4,
        holdSeconds: 7,
        exhaleSeconds: 8,
        holdAfterExhaleSeconds: 0,
        rounds: 4
    )

    static let calmBreath = BreathingPattern(
        id: "calm",
        name: "Calm Breath",
        description: "Simple slow breathing for relaxation",
        inhaleSeconds: 4,
        holdSeconds: 0,
        exhaleSeconds: 6,
        holdAfterExhaleSeconds: 2,
        rounds: 6
    )
}
