//
//  NavigationDestinations.swift
//  BloomHer
//
//  All typed navigation destination enums consumed by NavigationStack's
//  navigationDestination(for:) API. Each tab owns its own destination
//  namespace, which keeps push-path types disjoint and prevents accidental
//  cross-tab routing.
//
//  Adding a new destination:
//  1. Add a case to the relevant enum below.
//  2. Add a navigationDestination(for:) handler in the corresponding tab's
//     NavigationStack in MainTabView.
//  3. Implement a navigate(to:) helper on the matching Router if deep-linking
//     is needed.
//

import Foundation

// MARK: - HomeDestination

/// Navigation destinations originating from the Home tab.
///
/// Covers cycle detail, symptom logging, and all pregnancy / TTC tools
/// that surface as push-navigations from the Home dashboard.
enum HomeDestination: Hashable {
    /// Full-detail view for a specific calendar date.
    case cycleDetail(Date)
    /// Symptom logging sheet pushed from a date-row or the home card.
    case symptomLog(Date)
    /// Pregnancy week detail (week number 1-42).
    case pregnancyWeek(Int)
    /// Baby kick counting session.
    case kickCounter
    /// Contraction timing tool.
    case contractionTimer
    /// Daily water intake tracker.
    case waterTracker
    /// Full-screen affirmation card.
    case affirmation
}

// MARK: - CalendarDestination

/// Navigation destinations originating from the Calendar tab.
enum CalendarDestination: Hashable {
    /// Detail view for a specific day on the cycle calendar.
    case dayDetail(Date)
    /// Full cycle-history insights and charts.
    case cycleInsights
}

// MARK: - WellnessDestination

/// Navigation destinations originating from the Wellness tab.
///
/// Covers yoga routines, pelvic floor, breathing, journalling, and
/// supplemental self-care features.
enum WellnessDestination: Hashable {
    /// Browse routines filtered by exercise category.
    case routineList(ExerciseCategory)
    /// Detail view for a specific routine identified by its ID.
    case routineDetail(String)
    /// Active guided session for a specific routine.
    case activeRoutine(String)
    /// Full searchable yoga pose library.
    case poseLibrary
    /// Dedicated pelvic-floor exercise programme.
    case pelvicFloor
    /// Guided breathing exercise screen.
    case breathing
    /// Full-screen daily affirmation with share capability.
    case affirmationFull
    /// Free-form gratitude journalling view.
    case gratitudeJournal
    /// Phase-specific nutrition guidance.
    case nutritionTips
    /// Self-care idea browser.
    case selfCare
    /// Supplement and pill reminder configuration.
    case supplementReminder
}

// MARK: - InsightsDestination

/// Navigation destinations originating from the Insights tab.
enum InsightsDestination: Hashable {
    /// Detailed cycle-history insights and trend charts.
    case cycleInsights
    /// PDF report generator for sharing with a healthcare provider.
    case reportGenerator
    /// Symptom heat-map calendar view.
    case symptomHeatmap
    /// Mood pattern analysis over multiple cycles.
    case moodPatterns
}

// MARK: - ProfileDestination

/// Navigation destinations originating from the Profile / Settings tab.
enum ProfileDestination: Hashable {
    /// Data privacy controls and export options.
    case privacySettings
    /// Notification schedule and preference settings.
    case notificationSettings
    /// Theme mode (system / light / dark) preference.
    case appearanceSettings
    /// HealthKit read/write permission management.
    case healthKitSettings
    /// Partner invitation and sharing setup.
    case partnerSetup
    /// App version, credits, and open-source acknowledgements.
    case about
    /// Full medical disclaimer text.
    case medicalDisclaimer
    /// GDPR / data-deletion request flow.
    case dataDeletion
}
