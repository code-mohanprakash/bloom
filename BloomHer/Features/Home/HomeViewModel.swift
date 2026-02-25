//
//  HomeViewModel.swift
//  BloomHer
//
//  Observable view-model powering the Home dashboard.
//  Owns cycle state, today's log, water intake, and all mutations
//  that originate from quick-action buttons on the home screen.
//

import SwiftUI

// MARK: - HomeViewModel

/// Drives the Home dashboard — computes the current cycle phase, prediction,
/// cycle day, days-late state, and today's hydration total from the
/// underlying repositories and prediction service.
///
/// All mutations (adding water, logging period start) are performed here
/// and then `refresh()` is called so the derived state stays consistent.
@Observable
@MainActor
final class HomeViewModel {

    // MARK: - Displayed Data

    /// The latest cycle prediction. `nil` until the first `refresh()` call.
    var prediction: CyclePrediction?

    /// The user's current cycle phase, defaulting to `.follicular`.
    var currentPhase: CyclePhase = .follicular

    /// Day within the current cycle (1-based, day 1 = first day of last period).
    var cycleDay: Int = 1

    /// Predicted total cycle length in days.
    var cycleLength: Int = Constants.Cycle.defaultLength

    /// Number of days the period is overdue, or `nil` when not yet late.
    var daysLate: Int? = nil

    /// Today's persistent log record, or `nil` if none has been created yet.
    var todayLog: DailyLog?

    /// Cumulative water intake for today in millilitres.
    var waterIntake: Int = 0

    /// The user's display name loaded from `SettingsManager`.
    var userName: String = ""

    // MARK: - UI State

    /// Controls presentation of the quick symptom/log entry sheet.
    var showQuickLog: Bool = false

    /// Controls presentation of the full day detail sheet.
    var showDayDetail: Bool = false

    /// `true` while an async refresh is in-flight.
    var isLoading: Bool = false

    /// Non-nil when an error should be surfaced to the user.
    var errorMessage: String?

    // MARK: - Dependencies

    private let cycleRepository: CycleRepositoryProtocol
    private let predictionService: CyclePredictorProtocol
    private let settingsManager: SettingsManager

    // MARK: - Computed Properties

    /// Daily water goal from `SettingsManager`.
    var waterGoal: Int { settingsManager.waterGoalMl }

    /// Progress ratio (0–1) of today's water intake against the daily goal.
    var waterProgress: Double {
        guard waterGoal > 0 else { return 0 }
        return min(Double(waterIntake) / Double(waterGoal), 1.0)
    }

    /// Time-aware greeting including the user's name when available.
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12:  timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        default:      timeGreeting = "Good evening"
        }
        let name = settingsManager.userName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? timeGreeting : "\(timeGreeting), \(name)"
    }

    /// Returns `true` when the active cycle's end date is nil (period is active).
    var isPeriodActive: Bool {
        guard let cycle = cycleRepository.fetchActiveCycle() else { return false }
        return cycle.endDate == nil
    }

    /// Days until the next predicted period. `nil` when unavailable.
    var daysUntilNextPeriod: Int? {
        guard let prediction else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let next  = Calendar.current.startOfDay(for: prediction.predictedNextStart)
        guard next >= today else { return nil }
        return Calendar.current.dateComponents([.day], from: today, to: next).day
    }

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.cycleRepository   = dependencies.cycleRepository
        self.predictionService = dependencies.cyclePredictionService
        self.settingsManager   = dependencies.settingsManager
        self.userName          = dependencies.settingsManager.userName
    }

    // MARK: - Refresh

    /// Reloads all state from the data layer.
    ///
    /// Fetches cycles, runs the prediction algorithm, computes phase/day/lateness,
    /// and pulls today's log. Lightweight enough to call on every `.onAppear`
    /// and `onRefresh`.
    func refresh() {
        userName = settingsManager.userName

        let recentCycles = cycleRepository.fetchRecentCycles(count: Constants.Cycle.maxHistoryForPrediction)

        // Run prediction if we have at least one cycle recorded.
        if !recentCycles.isEmpty {
            let pred = predictionService.predictNextPeriod(from: recentCycles)
            prediction  = pred
            cycleLength = pred.predictedCycleLength
            daysLate    = predictionService.daysLate(prediction: pred)

            // Derive phase and cycle day from the most recent start date.
            if let lastStart = recentCycles.sorted(by: { $0.startDate < $1.startDate }).last?.startDate {
                currentPhase = predictionService.currentPhase(lastPeriodStart: lastStart, prediction: pred)
                cycleDay     = predictionService.cycleDay(from: lastStart)
            }
        } else {
            // No data yet — use defaults.
            prediction   = nil
            currentPhase = .follicular
            cycleDay     = 1
            cycleLength  = Constants.Cycle.defaultLength
            daysLate     = nil
        }

        // Fetch or leave nil (do not auto-create the log just for display).
        todayLog    = cycleRepository.fetchDailyLog(for: Date())
        waterIntake = todayLog?.waterIntakeMl ?? 0
    }

    // MARK: - Mutations

    /// Adds `ml` millilitres to today's water intake log.
    ///
    /// Creates the `DailyLog` record if it does not yet exist for today.
    /// Triggers medium haptic feedback on success.
    func addWater(ml: Int) {
        let log = cycleRepository.fetchOrCreateDailyLog(for: Date())
        log.waterIntakeMl += ml
        cycleRepository.saveDailyLog(log)
        todayLog    = log
        waterIntake = log.waterIntakeMl

        HapticManager.shared.medium()
    }

    /// Creates a new `CycleEntry` starting today and refreshes predictions.
    ///
    /// Should only be called when no active period is already in progress.
    /// Triggers success haptic feedback.
    func logPeriodStart() {
        let newCycle = CycleEntry(startDate: Calendar.current.startOfDay(for: Date()), isConfirmed: true)
        cycleRepository.saveCycle(newCycle)
        HapticManager.shared.success()
        refresh()
    }

    /// Marks the currently active period as ended (sets `endDate` to today).
    ///
    /// If there is no active open cycle this is a no-op.
    func endPeriod() {
        guard let activeCycle = cycleRepository.fetchActiveCycle(),
              activeCycle.endDate == nil else { return }
        activeCycle.endDate = Calendar.current.startOfDay(for: Date())
        cycleRepository.saveCycle(activeCycle)
        HapticManager.shared.success()
        refresh()
    }
}
