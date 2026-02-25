//
//  WellnessViewModel.swift
//  BloomHer
//
//  Observable view-model that manages all state for the Wellness tab.
//  Drives: daily affirmation, water tracking, gratitude journaling,
//  self-care suggestions, saved affirmations, and breathing patterns.
//

import SwiftUI
import Observation

// MARK: - WellnessViewModel

@Observable
@MainActor
final class WellnessViewModel {

    // MARK: - Published State

    /// The affirmation to surface today (phase-matched first, then universal).
    var dailyAffirmation: AffirmationContent?

    /// Current water intake in ml for today.
    var waterIntake: Int = 0

    /// Daily water goal in ml (from settings).
    var waterGoal: Int = 2000

    /// The user's current gratitude note (unsaved draft).
    var gratitudeNote: String = ""

    /// Phase-specific self-care suggestions for today.
    var selfCareSuggestions: [SelfCareItem] = []

    /// All affirmations the user has favourited.
    var savedAffirmations: [Affirmation] = []

    /// The user's active cycle phase (drives content filtering).
    var currentPhase: CyclePhase = .follicular

    /// All affirmation content, used for the full AffirmationCardView swipe deck.
    var allAffirmations: [AffirmationContent] = []

    /// Index of the currently visible affirmation card.
    var affirmationIndex: Int = 0

    /// Whether a gratitude save animation is in progress.
    var showGratitudeSaved: Bool = false

    /// Whether the daily affirmation is currently favourited.
    var isAffirmationFavourited: Bool = false

    /// Today's saved gratitude note text (persisted).
    var savedGratitudeNote: String = ""

    /// Consecutive days the user has logged gratitude.
    var gratitudeStreak: Int = 0

    // MARK: - Dependencies

    private let wellnessRepository: WellnessRepositoryProtocol
    private let cycleRepository: CycleRepositoryProtocol
    private let predictionService: CyclePredictorProtocol
    private let settingsManager: SettingsManager

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.wellnessRepository = dependencies.wellnessRepository
        self.cycleRepository    = dependencies.cycleRepository
        self.predictionService  = dependencies.cyclePredictionService
        self.settingsManager    = dependencies.settingsManager
    }

    // MARK: - Load

    /// Loads all content for the wellness tab. Call on `.onAppear`.
    func loadDailyContent() {
        loadPhase()
        loadWater()
        loadAffirmations()
        loadSelfCareSuggestions()
        loadSavedAffirmations()
        loadGratitudeNote()
        loadGratitudeStreak()
    }

    // MARK: - Water

    /// Adds `ml` millilitres to today's water intake and persists it.
    func addWater(ml: Int) {
        let log = cycleRepository.fetchOrCreateDailyLog(for: .now)
        log.waterIntakeMl += ml
        cycleRepository.saveDailyLog(log)
        waterIntake = log.waterIntakeMl
        BloomHerTheme.Haptics.medium()
    }

    /// Sets today's water goal (user override).
    func setWaterGoal(_ goal: Int) {
        waterGoal = goal
    }

    // MARK: - Gratitude

    /// Persists the current `gratitudeNote` to today's affirmation record.
    func saveGratitude() {
        guard !gratitudeNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let affirmation = wellnessRepository.fetchOrCreateAffirmation(
            for: .now,
            text: dailyAffirmation?.text ?? ""
        )
        affirmation.gratitudeEntry = gratitudeNote
        wellnessRepository.saveAffirmation(affirmation)
        savedGratitudeNote = gratitudeNote
        BloomHerTheme.Haptics.success()
        withAnimation(BloomHerTheme.Animation.standard) {
            showGratitudeSaved = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation(BloomHerTheme.Animation.standard) {
                    showGratitudeSaved = false
                }
            }
        }
        loadGratitudeStreak()
    }

    // MARK: - Affirmation Favourite

    /// Toggles the favourite state of the current daily affirmation.
    func toggleAffirmationFavourite() {
        guard let content = dailyAffirmation else { return }
        let affirmation = wellnessRepository.fetchOrCreateAffirmation(
            for: .now,
            text: content.text
        )
        affirmation.isFavourited.toggle()
        isAffirmationFavourited = affirmation.isFavourited
        wellnessRepository.saveAffirmation(affirmation)
        BloomHerTheme.Haptics.medium()
        loadSavedAffirmations()
    }

    /// Navigates to the next affirmation in the deck.
    func nextAffirmation() {
        guard !allAffirmations.isEmpty else { return }
        BloomHerTheme.Haptics.light()
        withAnimation(BloomHerTheme.Animation.standard) {
            affirmationIndex = (affirmationIndex + 1) % allAffirmations.count
        }
    }

    /// Navigates to the previous affirmation in the deck.
    func previousAffirmation() {
        guard !allAffirmations.isEmpty else { return }
        BloomHerTheme.Haptics.light()
        withAnimation(BloomHerTheme.Animation.standard) {
            affirmationIndex = (affirmationIndex - 1 + allAffirmations.count) % allAffirmations.count
        }
    }

    // MARK: - Self-Care

    /// Reloads mode-appropriate self-care suggestions.
    func loadSelfCareSuggestions() {
        switch settingsManager.appMode {
        case .cycle:
            selfCareSuggestions = Array(SelfCareData.items(for: currentPhase).prefix(6))
        case .pregnant:
            selfCareSuggestions = Array(SelfCareData.pregnancySafeItems.prefix(6))
        case .ttc:
            // TTC still uses cycle phases, same as cycle mode
            selfCareSuggestions = Array(SelfCareData.items(for: currentPhase).prefix(6))
        }
    }

    /// Marks a self-care item as completed or not.
    func toggleSelfCareItem(_ item: SelfCareItem) {
        if let index = selfCareSuggestions.firstIndex(where: { $0.id == item.id }) {
            selfCareSuggestions[index].isCompleted.toggle()
            BloomHerTheme.Haptics.medium()
        }
    }

    // MARK: - Private Loaders

    private func loadPhase() {
        let cycles = cycleRepository.fetchAllCycles()
        let sorted = cycles.sorted { $0.startDate < $1.startDate }
        guard let lastStart = sorted.last?.startDate else { return }
        let prediction = predictionService.predictNextPeriod(from: sorted)
        currentPhase = predictionService.currentPhase(
            lastPeriodStart: lastStart,
            prediction: prediction
        )
    }

    private func loadWater() {
        waterGoal = settingsManager.waterGoalMl
        let log = cycleRepository.fetchDailyLog(for: .now)
        waterIntake = log?.waterIntakeMl ?? 0
    }

    private func loadAffirmations() {
        let appMode = settingsManager.appMode

        let phaseAffirmations: [AffirmationContent]
        let universal: [AffirmationContent]

        switch appMode {
        case .cycle:
            phaseAffirmations = AffirmationData.affirmations(for: currentPhase)
            universal = AffirmationData.universalAffirmations

        case .pregnant:
            // Pregnancy mode: use pregnancy-safe affirmations (pregnancy + universal)
            phaseAffirmations = AffirmationData.pregnancySafeAffirmations
            universal = []

        case .ttc:
            // TTC mode: combine TTC-specific with phase-filtered cycle affirmations
            let ttcSpecific = AffirmationData.ttcAffirmations
            let phaseFiltered = AffirmationData.affirmations(for: currentPhase)
            phaseAffirmations = ttcSpecific + phaseFiltered
            universal = AffirmationData.universalAffirmations
        }

        allAffirmations = phaseAffirmations + universal

        // Pick today's affirmation deterministically by day-of-year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let pool = phaseAffirmations.isEmpty ? (universal.isEmpty ? AffirmationData.universalAffirmations : universal) : phaseAffirmations
        dailyAffirmation = pool[dayOfYear % pool.count]

        // Resolve saved favourite state
        let saved = wellnessRepository.fetchAffirmation(for: .now)
        isAffirmationFavourited = saved?.isFavourited ?? false
    }

    private func loadSavedAffirmations() {
        savedAffirmations = wellnessRepository.fetchFavouritedAffirmations()
    }

    private func loadGratitudeNote() {
        let saved = wellnessRepository.fetchAffirmation(for: .now)
        savedGratitudeNote = saved?.gratitudeEntry ?? ""
        gratitudeNote = savedGratitudeNote
    }

    private func loadGratitudeStreak() {
        // Count consecutive days going backwards from yesterday that have a gratitude entry
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now)) ?? .now

        // Include today if it has an entry
        if let today = wellnessRepository.fetchAffirmation(for: .now),
           let entry = today.gratitudeEntry, !entry.isEmpty {
            streak += 1
        }

        for _ in 0..<364 {
            if let aff = wellnessRepository.fetchAffirmation(for: checkDate),
               let entry = aff.gratitudeEntry, !entry.isEmpty {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        gratitudeStreak = streak
    }
}

