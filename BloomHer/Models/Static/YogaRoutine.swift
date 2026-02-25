import Foundation

enum Difficulty: String, Codable, CaseIterable, Hashable {
    case beginner, intermediate, advanced

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .beginner: return "leaf"
        case .intermediate: return "flame"
        case .advanced: return "bolt"
        }
    }
}

struct YogaPoseReference: Codable, Hashable, Identifiable {
    var id: String { poseId }
    let poseId: String
    let holdDurationSeconds: Int
    let repetitions: Int?
    let notes: String?

    init(poseId: String, holdDurationSeconds: Int = 30, repetitions: Int? = nil, notes: String? = nil) {
        self.poseId = poseId
        self.holdDurationSeconds = holdDurationSeconds
        self.repetitions = repetitions
        self.notes = notes
    }
}

struct YogaRoutine: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let durationMinutes: Int
    let difficulty: Difficulty
    let description: String
    let poses: [YogaPoseReference]
    let safetyNotes: [String]
    let contraindications: [String]
    let isPremium: Bool

    var poseCount: Int { poses.count }
}
