import SwiftUI

/// Represents the four primary phases of the menstrual cycle.
public enum CyclePhase: String, Codable, CaseIterable, Hashable {
    case menstrual
    case follicular
    case ovulation
    case luteal

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .menstrual:  return "Menstrual"
        case .follicular: return "Follicular"
        case .ovulation:  return "Ovulation"
        case .luteal:     return "Luteal"
        }
    }

    /// Custom asset name that represents this cycle phase.
    var icon: String {
        switch self {
        case .menstrual:  return "phase-menstrual"
        case .follicular: return "phase-follicular"
        case .ovulation:  return "phase-ovulation"
        case .luteal:     return "phase-luteal"
        }
    }

    /// Custom asset image name for this cycle phase (same as icon, kept for compatibility).
    var customImage: String? { icon }

    /// A concise one-line description of what happens during this phase.
    var description: String {
        switch self {
        case .menstrual:
            return "The uterine lining sheds as oestrogen and progesterone reach their lowest levels."
        case .follicular:
            return "Follicles develop in the ovaries and oestrogen rises, boosting energy and mood."
        case .ovulation:
            return "A mature egg is released from the ovary — fertility peaks at this phase."
        case .luteal:
            return "Progesterone rises to prepare the uterus, often bringing PMS symptoms."
        }
    }

    /// The SwiftUI `Color` associated with this cycle phase.
    /// Hex values are defined inline to avoid circular dependency on a shared colour asset.
    var color: Color {
        switch self {
        case .menstrual:  return Color(hex: "#E88B9C")
        case .follicular: return Color(hex: "#A8D5BA")
        case .ovulation:  return Color(hex: "#F9D5A7")
        case .luteal:     return Color(hex: "#B8C9E8")
        }
    }

    /// An emoji character that represents this cycle phase.
    var emoji: String {
        switch self {
        case .menstrual:  return "🌑"
        case .follicular: return "🌱"
        case .ovulation:  return "🌕"
        case .luteal:     return "🍂"
        }
    }
}
