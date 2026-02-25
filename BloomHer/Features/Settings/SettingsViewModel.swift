//
//  SettingsViewModel.swift
//  BloomHer
//
//  Observable view-model for the Settings screen.
//  Exposes computed properties consumed by the UI and performs
//  side-effecting mutations (mode change, data deletion).
//

import SwiftUI
import SwiftData

// MARK: - SettingsViewModel

/// Drives the Settings screen and its sub-views.
///
/// The view-model holds the `SettingsManager` (which is itself `@Observable`)
/// so SwiftUI automatically re-renders any view that reads a settings property.
/// Destructive operations (data deletion, mode change) are gated behind
/// confirmation dialogs controlled by Boolean flags on this type.
@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - Dependencies

    let settingsManager: SettingsManager
    let healthKitService: HealthKitServiceProtocol

    // MARK: - Dialog State

    /// Controls the "Delete All Data" confirmation alert.
    var showDeleteConfirmation: Bool = false

    /// Controls the "Change Mode" confirmation alert when mode switching
    /// could cause data loss (e.g., switching from pregnant to cycle).
    var showModeChangeConfirmation: Bool = false

    /// The mode the user has selected but not yet confirmed.
    var pendingMode: AppMode? = nil

    /// Non-nil while a data-deletion operation is in progress.
    var isDeletingData: Bool = false

    /// Non-nil after an operation completes, shown as a brief banner.
    var feedbackMessage: String? = nil

    // MARK: - Computed Properties

    /// The CFBundleShortVersionString from the main bundle, or "1.0" as fallback.
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// The CFBundleVersion build number, or "1" as fallback.
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Version string formatted as "1.0 (42)".
    var versionString: String { "\(appVersion) (\(buildNumber))" }

    /// `true` when HealthKit is available and already authorized.
    var healthKitConnected: Bool { healthKitService.isAuthorized }

    /// `true` when HealthKit is available on this device.
    var healthKitAvailable: Bool { healthKitService.isAvailable }

    /// All tracking mode options with their display metadata.
    var appModeOptions: [(mode: AppMode, title: String, subtitle: String, icon: String)] {
        [
            (.cycle,    "Cycle Tracking",    "Track your menstrual cycle",     "icon-cycle"),
            (.pregnant, "Pregnancy Mode",    "Week-by-week pregnancy guide",   "iconpreg"),
            (.ttc,      "Trying to Conceive","Fertility & ovulation tracking", "icon-ttc")
        ]
    }

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.settingsManager  = dependencies.settingsManager
        self.healthKitService = dependencies.healthKitService
    }

    // MARK: - Mode Change

    /// Begins the mode-change flow. Shows a confirmation dialog if mode differs.
    func requestModeChange(to mode: AppMode) {
        guard mode != settingsManager.appMode else { return }
        pendingMode              = mode
        showModeChangeConfirmation = true
    }

    /// Applies the pending mode change after user confirmation.
    func confirmModeChange() {
        guard let mode = pendingMode else { return }
        settingsManager.appMode = mode
        pendingMode = nil
        BloomHerTheme.Haptics.success()
    }

    /// Cancels a pending mode change.
    func cancelModeChange() {
        pendingMode = nil
    }

    // MARK: - Data Deletion

    /// Deletes all app health data from the SwiftData store.
    ///
    /// - Parameter modelContext: The SwiftData context from the SwiftUI environment.
    func deleteAllData(modelContext: ModelContext) {
        isDeletingData = true
        BloomHerTheme.Haptics.error()

        // Delete all SwiftData models that make up health data.
        do {
            try modelContext.delete(model: CycleEntry.self)
            try modelContext.delete(model: DailyLog.self)
            try modelContext.delete(model: PregnancyProfile.self)
            try modelContext.delete(model: KickSession.self)
            try modelContext.delete(model: ContractionEntry.self)
            try modelContext.delete(model: YogaSession.self)
            try modelContext.delete(model: Appointment.self)
            try modelContext.delete(model: WeightEntry.self)
            try modelContext.delete(model: OPKResult.self)
            try modelContext.delete(model: BBTEntry.self)
            try modelContext.delete(model: Affirmation.self)
            try modelContext.delete(model: PartnerShare.self)
            try modelContext.delete(model: WeeklyChecklist.self)
            try modelContext.save()
            settingsManager.resetToDefaults()
            feedbackMessage = "All data deleted successfully."
        } catch {
            feedbackMessage = "Deletion failed: \(error.localizedDescription)"
        }
        isDeletingData = false
    }

    // MARK: - HealthKit

    /// Requests HealthKit authorisation if not already granted.
    func connectHealthKit() async {
        guard healthKitAvailable else { return }
        do {
            try await healthKitService.requestAuthorization()
            feedbackMessage = "Apple Health connected."
            BloomHerTheme.Haptics.success()
        } catch {
            feedbackMessage = "Could not connect to Apple Health."
            BloomHerTheme.Haptics.error()
        }
    }
}
