import Foundation

/// Represents the primary mode the user has selected for their BloomHer experience.
/// Each mode tailors the app's content, tracking features, and exercise recommendations.
public enum AppMode: String, Codable, CaseIterable, Hashable {
    case cycle
    case pregnant
    case ttc

    /// A human-readable label suitable for display in the UI.
    var displayName: String {
        switch self {
        case .cycle:    return "Cycle Tracking"
        case .pregnant: return "Pregnancy"
        case .ttc:      return "Trying to Conceive"
        }
    }

    /// A custom asset name that represents this app mode.
    var icon: String {
        switch self {
        case .cycle:    return "icon-cycle"
        case .pregnant: return "iconpreg"
        case .ttc:      return "icon-ttc"
        }
    }

    /// A short description explaining what this mode focuses on.
    var description: String {
        switch self {
        case .cycle:
            return "Track your menstrual cycle, symptoms, and mood to understand your body's natural rhythms."
        case .pregnant:
            return "Follow your pregnancy week by week with tailored workouts, nutrition, and health insights."
        case .ttc:
            return "Optimise your fertility window with ovulation tracking, OPK logging, and conception guidance."
        }
    }
}
