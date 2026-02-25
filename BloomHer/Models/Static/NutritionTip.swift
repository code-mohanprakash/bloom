import Foundation

struct NutritionTip: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let foods: [String]              // recommended foods
    let nutrient: String             // key nutrient (e.g., "Iron", "Folic Acid")
    let phase: CyclePhase?           // nil = general
    let isPregnancy: Bool
    let trimester: Int?              // nil if not pregnancy-specific
    let dailyAmount: String?         // e.g., "400mcg", "2.3L"
    let icon: String                 // SF Symbol
    let source: String               // e.g., "NHS", "IOM"

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        foods: [String],
        nutrient: String,
        phase: CyclePhase? = nil,
        isPregnancy: Bool = false,
        trimester: Int? = nil,
        dailyAmount: String? = nil,
        icon: String = "leaf",
        source: String = "NHS"
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.foods = foods
        self.nutrient = nutrient
        self.phase = phase
        self.isPregnancy = isPregnancy
        self.trimester = trimester
        self.dailyAmount = dailyAmount
        self.icon = icon
        self.source = source
    }
}
