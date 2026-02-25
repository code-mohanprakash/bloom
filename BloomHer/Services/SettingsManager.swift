import Foundation
import SwiftUI

// MARK: - ThemeMode

/// Controls the colour-scheme preference applied to the root window.
enum ThemeMode: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    /// Cycles to the next theme in the sequence: dark → light → system → dark
    var next: ThemeMode {
        switch self {
        case .dark:   return .light
        case .light:  return .system
        case .system: return .dark
        }
    }

    /// Icon asset name representing this mode.
    var icon: String {
        switch self {
        case .dark:   return "moon-stars"
        case .light:  return "sparkles"
        case .system: return "swap"
        }
    }

    /// Short label for compact UI (e.g. theme toggle capsule).
    var shortLabel: String {
        switch self {
        case .dark:   return "Dark"
        case .light:  return "Light"
        case .system: return "Auto"
        }
    }

    /// The SwiftUI `ColorScheme` value that should be applied to the scene,
    /// or `nil` when the system preference should be followed.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - UserDefaults Keys

private extension String {
    static let hasCompletedOnboarding = "settings.hasCompletedOnboarding"
    static let appMode                = "settings.appMode"
    static let userName               = "settings.userName"
    static let waterGoalMl            = "settings.waterGoalMl"
    static let notificationsEnabled   = "settings.notificationsEnabled"
    static let periodReminderEnabled  = "settings.periodReminderEnabled"
    static let pillReminderEnabled    = "settings.pillReminderEnabled"
    static let pillReminderTime       = "settings.pillReminderTime"
    static let iCloudSyncEnabled      = "settings.iCloudSyncEnabled"
    static let hapticFeedbackEnabled  = "settings.hapticFeedbackEnabled"
    static let selectedThemeMode      = "settings.selectedThemeMode"
    static let defaultCycleLength     = "settings.defaultCycleLength"
    static let defaultPeriodLength    = "settings.defaultPeriodLength"
}

// MARK: - SettingsManager

/// Central, observable store for all user preferences.
///
/// Values are persisted to `UserDefaults.standard` on every write via
/// `didSet` observers.  The class is marked `@Observable` (Swift 5.9
/// Observation framework) so that SwiftUI views automatically track the
/// specific properties they access — no manual `objectWillChange` calls needed.
///
/// Usage:
/// ```swift
/// @Environment(SettingsManager.self) private var settings
/// settings.appMode = .pregnant
/// ```
@Observable
final class SettingsManager {

    // MARK: - Stored Properties

    /// Whether the user has completed the first-run onboarding flow.
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: .hasCompletedOnboarding) }
    }

    /// The primary tracking mode the user has selected.
    var appMode: AppMode {
        didSet { persist(appMode, forKey: .appMode) }
    }

    /// The user's display name (first name only, shown on the Home screen).
    var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: .userName) }
    }

    /// Daily water intake target in millilitres.
    var waterGoalMl: Int {
        didSet { UserDefaults.standard.set(waterGoalMl, forKey: .waterGoalMl) }
    }

    /// Master toggle: when false, no local notifications are scheduled.
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: .notificationsEnabled) }
    }

    /// Whether to schedule a period-prediction reminder notification.
    var periodReminderEnabled: Bool {
        didSet { UserDefaults.standard.set(periodReminderEnabled, forKey: .periodReminderEnabled) }
    }

    /// Whether to schedule a daily pill/supplement reminder notification.
    var pillReminderEnabled: Bool {
        didSet { UserDefaults.standard.set(pillReminderEnabled, forKey: .pillReminderEnabled) }
    }

    /// The time-of-day at which the daily pill reminder fires.
    var pillReminderTime: Date {
        didSet { UserDefaults.standard.set(pillReminderTime.timeIntervalSince1970, forKey: .pillReminderTime) }
    }

    /// Whether iCloud sync is enabled.  Changing this requires a ModelContainer
    /// reconfiguration, handled by the app coordinator.
    var iCloudSyncEnabled: Bool {
        didSet { UserDefaults.standard.set(iCloudSyncEnabled, forKey: .iCloudSyncEnabled) }
    }

    /// Whether haptic feedback is triggered for key interactions.
    var hapticFeedbackEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticFeedbackEnabled, forKey: .hapticFeedbackEnabled) }
    }

    /// The colour-scheme preference applied to the root scene.
    var selectedThemeMode: ThemeMode {
        didSet { persist(selectedThemeMode, forKey: .selectedThemeMode) }
    }

    /// Fallback cycle length (days) used when the algorithm has insufficient data.
    var defaultCycleLength: Int {
        didSet { UserDefaults.standard.set(defaultCycleLength, forKey: .defaultCycleLength) }
    }

    /// Fallback period length (days) used when no end-dates have been recorded.
    var defaultPeriodLength: Int {
        didSet { UserDefaults.standard.set(defaultPeriodLength, forKey: .defaultPeriodLength) }
    }

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard

        self.hasCompletedOnboarding = defaults.bool(forKey: .hasCompletedOnboarding)
        self.appMode                = Self.decodedValue(AppMode.self, forKey: .appMode) ?? .cycle
        self.userName               = defaults.string(forKey: .userName) ?? ""
        self.waterGoalMl            = defaults.integer(forKey: .waterGoalMl).nonZero ?? Constants.Hydration.defaultGoalMl
        self.notificationsEnabled   = defaults.bool(forKey: .notificationsEnabled)
        self.periodReminderEnabled  = defaults.bool(forKey: .periodReminderEnabled)
        self.pillReminderEnabled    = defaults.bool(forKey: .pillReminderEnabled)
        self.iCloudSyncEnabled      = defaults.bool(forKey: .iCloudSyncEnabled)
        self.hapticFeedbackEnabled  = defaults.object(forKey: .hapticFeedbackEnabled) as? Bool ?? true
        self.selectedThemeMode      = Self.decodedValue(ThemeMode.self, forKey: .selectedThemeMode) ?? .dark
        self.defaultCycleLength     = defaults.integer(forKey: .defaultCycleLength).nonZero ?? Constants.Cycle.defaultLength
        self.defaultPeriodLength    = defaults.integer(forKey: .defaultPeriodLength).nonZero ?? Constants.Cycle.defaultPeriodLength

        // Pill reminder time: default to 08:00 today if not yet stored.
        let savedInterval = defaults.double(forKey: .pillReminderTime)
        if savedInterval > 0 {
            self.pillReminderTime = Date(timeIntervalSince1970: savedInterval)
        } else {
            var comps       = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour      = 8
            comps.minute    = 0
            comps.second    = 0
            self.pillReminderTime = Calendar.current.date(from: comps) ?? Date()
        }
    }

    // MARK: - Reset

    /// Wipes all persisted preferences and restores factory defaults.
    /// Called during account deletion or onboarding restart.
    func resetToDefaults() {
        hasCompletedOnboarding = false
        appMode                = .cycle
        userName               = ""
        waterGoalMl            = Constants.Hydration.defaultGoalMl
        notificationsEnabled   = false
        periodReminderEnabled  = false
        pillReminderEnabled    = false
        iCloudSyncEnabled      = false
        hapticFeedbackEnabled  = true
        selectedThemeMode      = .dark
        defaultCycleLength     = Constants.Cycle.defaultLength
        defaultPeriodLength    = Constants.Cycle.defaultPeriodLength

        var comps    = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour   = 8
        comps.minute = 0
        comps.second = 0
        pillReminderTime = Calendar.current.date(from: comps) ?? Date()
    }

    // MARK: - Private Helpers

    /// Encodes a `Codable` value as JSON and stores it under `key`.
    private func persist<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// Decodes a `Codable` value from the JSON data stored under `key`, or returns nil.
    private static func decodedValue<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Int Helper

private extension Int {
    /// Returns self if > 0, otherwise nil (used for UserDefaults integer reads where 0 means "not set").
    var nonZero: Int? { self > 0 ? self : nil }
}
