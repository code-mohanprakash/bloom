import Foundation

enum SafetyLevel: String, Codable, CaseIterable, Hashable {
    case safe, modified, avoid

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .safe:     return "checkmark-circle"
        case .modified: return "warning"
        case .avoid:    return "xmark-circle"
        }
    }
}

struct PregnancySafetyMatrix: Codable, Hashable {
    let trimester1: SafetyLevel
    let trimester2: SafetyLevel
    let trimester3: SafetyLevel
    let postpartum: SafetyLevel
    let notes: String?

    static let allSafe = PregnancySafetyMatrix(
        trimester1: .safe, trimester2: .safe, trimester3: .safe, postpartum: .safe, notes: nil
    )
}

struct YogaPose: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let sanskritName: String?
    let instructions: [String]
    let benefits: [String]
    let contraindications: [String]
    let defaultHoldDurationSeconds: Int
    let difficulty: Difficulty
    let safetyMatrix: PregnancySafetyMatrix
    let muscleGroups: [String]

    func isSafe(forTrimester trimester: Int) -> SafetyLevel {
        switch trimester {
        case 1: return safetyMatrix.trimester1
        case 2: return safetyMatrix.trimester2
        case 3: return safetyMatrix.trimester3
        default: return safetyMatrix.postpartum
        }
    }
}
