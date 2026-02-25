//
//  OnboardingViewModel.swift
//  BloomHer
//
//  Observable view-model that owns all state for the five-page onboarding
//  flow.  A single instance is created in OnboardingFlow and passed down to
//  child page views via @Bindable.
//
//  Page routing:
//    Page 0 — WelcomePageView
//    Page 1 — ModeSelectionPageView
//    Page 2 — CycleHistoryPageView  (cycle / ttc paths) or PregnancySetupPage (pregnant)
//    Page 3 — PrivacyPromisePageView
//    Page 4 — PersonalizationPageView
//

import SwiftUI
import SwiftData

// MARK: - OnboardingViewModel

@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: - Navigation

    var currentPage: Int = 0
    let totalPages: Int = 5

    // MARK: - Page 1: Mode Selection

    var selectedMode: AppMode = .cycle

    // MARK: - Page 2: Cycle History (cycle / ttc)

    var lastPeriodStartDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    var typicalCycleLength: Double = 28
    var typicalPeriodLength: Double = 5

    // MARK: - Page 2 alt: Pregnancy Setup (pregnant)

    var lmpDate: Date = Calendar.current.date(byAdding: .day, value: -42, to: Date()) ?? Date()
    var knowsConceptionDate: Bool = false
    var conceptionDate: Date = Calendar.current.date(byAdding: .day, value: -28, to: Date()) ?? Date()

    // MARK: - Page 4: Personalisation

    var userName: String = ""
    var enableNotifications: Bool = true
    var enableHealthKit: Bool = true
    var enableiCloud: Bool = false

    // MARK: - Loading / Completion

    var isCompleting: Bool = false
    var completionError: String? = nil

    // MARK: - Derived

    /// Whether the user can advance past the current page.
    var canAdvance: Bool {
        switch currentPage {
        case 0: return true                          // Welcome — always ok
        case 1: return true                          // Mode is always pre-selected
        case 2: return cyclePageIsValid              // Date / LMP validation
        case 3: return true                          // Privacy — always ok
        case 4: return !isCompleting                 // Not mid-save
        default: return false
        }
    }

    private var cyclePageIsValid: Bool {
        if selectedMode == .pregnant {
            // LMP must not be in the future and not more than 10 months ago
            let now = Date()
            let tenMonthsAgo = Calendar.current.date(byAdding: .month, value: -10, to: now) ?? now
            guard lmpDate <= now, lmpDate >= tenMonthsAgo else { return false }
            if knowsConceptionDate {
                return conceptionDate <= now && conceptionDate >= tenMonthsAgo
            }
            return true
        } else {
            // Last period must be in the past and within the last 3 cycles
            let now = Date()
            let maxDaysBack = typicalCycleLength * 3
            let earliest = Calendar.current.date(byAdding: .day, value: -Int(maxDaysBack), to: now) ?? now
            return lastPeriodStartDate <= now && lastPeriodStartDate >= earliest
        }
    }

    // MARK: - Navigation Actions

    func advance() {
        guard canAdvance, currentPage < totalPages - 1 else { return }
        withAnimation(BloomHerTheme.Animation.standard) {
            currentPage += 1
        }
    }

    func goBack() {
        guard currentPage > 0 else { return }
        withAnimation(BloomHerTheme.Animation.standard) {
            currentPage -= 1
        }
    }

    /// Skip directly to the last page (Personalisation).
    func skip() {
        withAnimation(BloomHerTheme.Animation.standard) {
            currentPage = totalPages - 1
        }
    }

    // MARK: - Completion

    /// Persists all collected settings and seeds initial data, then marks
    /// onboarding complete so the root view transitions to the main app.
    func completeOnboarding(dependencies: AppDependencies) async {
        guard !isCompleting else { return }
        isCompleting = true
        completionError = nil

        let settings = dependencies.settingsManager

        // 1. Core preferences
        settings.appMode = selectedMode
        settings.userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.defaultCycleLength = Int(typicalCycleLength)
        settings.defaultPeriodLength = Int(typicalPeriodLength)
        settings.iCloudSyncEnabled = enableiCloud

        // 2. HealthKit authorisation
        if enableHealthKit {
            do {
                try await dependencies.healthKitService.requestAuthorization()
            } catch {
                // HealthKit failure is non-fatal — user can enable later in Settings
            }
        }

        // 3. Notification permission
        if enableNotifications {
            let granted = await dependencies.notificationService.requestPermission()
            settings.notificationsEnabled = granted
            settings.periodReminderEnabled = granted
        }

        // 4. Seed initial cycle / pregnancy data
        await seedInitialData(dependencies: dependencies)

        // 5. Mark onboarding done — this triggers the root view transition
        settings.hasCompletedOnboarding = true

        isCompleting = false
    }

    // MARK: - Private Seed Helpers

    private func seedInitialData(dependencies: AppDependencies) async {
        switch selectedMode {
        case .cycle, .ttc:
            await seedCycleEntry(dependencies: dependencies)
        case .pregnant:
            await seedPregnancyProfile(dependencies: dependencies)
        }
    }

    private func seedCycleEntry(dependencies: AppDependencies) async {
        let entry = CycleEntry(startDate: lastPeriodStartDate, isConfirmed: true)
        entry.cycleLengthDays = Int(typicalCycleLength)
        dependencies.cycleRepository.saveCycle(entry)
    }

    private func seedPregnancyProfile(dependencies: AppDependencies) async {
        let effectiveLMP = knowsConceptionDate
            ? Calendar.current.date(byAdding: .day, value: -14, to: conceptionDate) ?? lmpDate
            : lmpDate

        let profile = PregnancyProfile(lmpDate: effectiveLMP)
        dependencies.pregnancyRepository.savePregnancy(profile)
    }
}
