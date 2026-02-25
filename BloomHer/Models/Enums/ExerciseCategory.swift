import Foundation

/// Represents curated exercise programme categories tailored to reproductive health phases.
enum ExerciseCategory: String, Codable, CaseIterable, Hashable {
    case menstrualYoga
    case follicularEnergy
    case ovulationPower
    case lutealWindDown
    case prenatalT1
    case prenatalT2
    case prenatalT3
    case postpartumRecovery
    case labourPrep
    case pelvicFloor
    case breathing

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .menstrualYoga:     return "Menstrual Yoga"
        case .follicularEnergy:  return "Follicular Energy"
        case .ovulationPower:    return "Ovulation Power"
        case .lutealWindDown:    return "Luteal Wind Down"
        case .prenatalT1:        return "Prenatal — Trimester 1"
        case .prenatalT2:        return "Prenatal — Trimester 2"
        case .prenatalT3:        return "Prenatal — Trimester 3"
        case .postpartumRecovery: return "Postpartum Recovery"
        case .labourPrep:        return "Labour Prep"
        case .pelvicFloor:       return "Pelvic Floor"
        case .breathing:         return "Breathing"
        }
    }

    /// A custom asset name that visually represents this exercise category.
    var icon: String {
        switch self {
        case .menstrualYoga:      return "yoga"
        case .follicularEnergy:   return "figure-stand"
        case .ovulationPower:     return "flame"
        case .lutealWindDown:     return "meditation"
        case .prenatalT1:         return "yoga"
        case .prenatalT2:         return "yoga"
        case .prenatalT3:         return "yoga"
        case .postpartumRecovery: return "figure-stand"
        case .labourPrep:         return "meditation"
        case .pelvicFloor:        return "pelvic-floor"
        case .breathing:          return "breathing"
        }
    }

    /// A short description explaining the purpose of this exercise category.
    var description: String {
        switch self {
        case .menstrualYoga:
            return "Gentle yoga flows to ease cramping and restore comfort during menstruation."
        case .follicularEnergy:
            return "Higher-intensity cardio and strength work aligned with rising oestrogen."
        case .ovulationPower:
            return "Peak-performance training timed with your most energetic cycle phase."
        case .lutealWindDown:
            return "Calming movement to support the body as progesterone rises."
        case .prenatalT1:
            return "Safe, low-impact exercise for the first trimester of pregnancy."
        case .prenatalT2:
            return "Modified strength and mobility work suited to the second trimester."
        case .prenatalT3:
            return "Gentle preparation workouts for the final trimester of pregnancy."
        case .postpartumRecovery:
            return "Progressive rehabilitation to restore core and pelvic strength after birth."
        case .labourPrep:
            return "Mobility, breathing, and positioning exercises to prepare for labour."
        case .pelvicFloor:
            return "Targeted exercises to strengthen and rehabilitate the pelvic floor muscles."
        case .breathing:
            return "Breath-work techniques for relaxation, labour, and recovery."
        }
    }

    /// Indicates whether this category belongs to a prenatal programme.
    var isPrenatal: Bool {
        switch self {
        case .prenatalT1, .prenatalT2, .prenatalT3, .labourPrep:
            return true
        default:
            return false
        }
    }

    /// Indicates whether this category belongs to a postpartum programme.
    var isPostpartum: Bool {
        switch self {
        case .postpartumRecovery:
            return true
        default:
            return false
        }
    }
}
