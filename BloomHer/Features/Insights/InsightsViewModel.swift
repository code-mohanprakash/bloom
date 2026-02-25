//
//  InsightsViewModel.swift
//  BloomHer
//
//  Observable view-model powering the Insights & Reports tab.
//  Aggregates cycle history, daily logs, symptom frequencies, mood
//  distributions, and phase-grouped breakdowns for chart views.
//

import SwiftUI

// MARK: - InsightsViewModel

/// Drives the Insights tab — computes cycle statistics, symptom and mood
/// frequencies, phase-grouped breakdowns, and exposes chart-ready data
/// derived from the underlying repositories and prediction service.
///
/// All aggregation work happens inside `refresh()` so each sub-view can
/// trigger a reload on `.onAppear` without duplicating fetch logic.
@Observable
@MainActor
final class InsightsViewModel {

    // MARK: - Cycle Data

    /// All cycle entries sorted by start date ascending.
    var cycles: [CycleEntry] = []

    /// All daily logs sorted by date ascending.
    var dailyLogs: [DailyLog] = []

    // MARK: - Prediction

    /// The latest cycle prediction. `nil` until the first `refresh()` call.
    var prediction: CyclePrediction?

    /// The user's current cycle phase, defaulting to `.follicular`.
    var currentPhase: CyclePhase = .follicular

    // MARK: - Cycle Statistics

    /// Weighted average cycle length in days across all recorded cycles.
    var averageCycleLength: Int = 0

    /// The shortest recorded cycle in days.
    var shortestCycle: Int = 0

    /// The longest recorded cycle in days.
    var longestCycle: Int = 0

    /// Total number of confirmed cycles recorded.
    var totalCyclesTracked: Int = 0

    /// `true` when cycle length variability exceeds the irregularity threshold.
    var isIrregular: Bool = false

    // MARK: - Chart Data

    /// Indexed cycle lengths for the line chart, ordered oldest → newest.
    /// Each element carries a 1-based cycle index and its length in days.
    var cycleLengths: [(cycle: Int, length: Int)] = []

    // MARK: - Symptom Analytics

    /// Top 10 symptoms sorted by frequency descending.
    var symptomFrequencies: [(symptom: Symptom, count: Int)] = []

    /// Symptom occurrence counts grouped by cycle phase, then by symptom.
    var symptomsByPhase: [CyclePhase: [Symptom: Int]] = [:]

    // MARK: - Mood Analytics

    /// Top 10 moods sorted by frequency descending.
    var moodFrequencies: [(mood: Mood, count: Int)] = []

    /// Mood occurrence counts grouped by cycle phase, then by mood.
    var moodsByPhase: [CyclePhase: [Mood: Int]] = [:]

    // MARK: - UI State

    /// `true` while an async refresh is in-flight.
    var isLoading: Bool = false

    /// Non-nil when an error should be surfaced to the user.
    var errorMessage: String?

    // MARK: - Dependencies

    private let cycleRepository: CycleRepositoryProtocol
    private let predictionService: CyclePredictorProtocol

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.cycleRepository   = dependencies.cycleRepository
        self.predictionService = dependencies.cyclePredictionService
    }

    // MARK: - Refresh

    /// Reloads all insights state from the data layer.
    ///
    /// Fetches all cycles and logs, runs the prediction algorithm, computes
    /// cycle statistics, and aggregates symptom/mood frequencies. Lightweight
    /// enough to call on every `.onAppear`.
    func refresh() {
        isLoading = true
        defer { isLoading = false }

        // ----------------------------------------------------------------
        // 1. Fetch raw data
        // ----------------------------------------------------------------
        let allCycles = cycleRepository.fetchAllCycles()
            .sorted { $0.startDate < $1.startDate }
        cycles = allCycles
        totalCyclesTracked = allCycles.count

        // ----------------------------------------------------------------
        // 2. Derive cycle lengths from consecutive start dates
        // ----------------------------------------------------------------
        var derivedLengths: [(cycle: Int, length: Int)] = []
        for i in 1..<max(1, allCycles.count) {
            let days = Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: allCycles[i - 1].startDate),
                to:   Calendar.current.startOfDay(for: allCycles[i].startDate)
            ).day ?? 0
            // Clamp to plausible range
            if days >= 10 && days <= 60 {
                derivedLengths.append((cycle: i, length: days))
            }
        }
        cycleLengths = derivedLengths

        // ----------------------------------------------------------------
        // 3. Cycle statistics
        // ----------------------------------------------------------------
        if derivedLengths.isEmpty {
            averageCycleLength = Constants.Cycle.defaultLength
            shortestCycle      = 0
            longestCycle       = 0
        } else {
            let lengths = derivedLengths.map(\.length)
            let total   = lengths.reduce(0, +)
            averageCycleLength = Int((Double(total) / Double(lengths.count)).rounded())
            shortestCycle      = lengths.min() ?? 0
            longestCycle       = lengths.max() ?? 0
        }

        // ----------------------------------------------------------------
        // 4. Run prediction if we have data
        // ----------------------------------------------------------------
        if allCycles.count >= 2 {
            let pred       = predictionService.predictNextPeriod(from: allCycles)
            prediction     = pred
            isIrregular    = pred.isIrregular

            if let lastStart = allCycles.last?.startDate {
                currentPhase = predictionService.currentPhase(
                    lastPeriodStart: lastStart,
                    prediction: pred
                )
            }
        } else {
            prediction   = nil
            isIrregular  = false
            currentPhase = .follicular
        }

        // ----------------------------------------------------------------
        // 5. Fetch all logs
        // ----------------------------------------------------------------
        guard !allCycles.isEmpty else {
            dailyLogs          = []
            symptomFrequencies = []
            moodFrequencies    = []
            symptomsByPhase    = [:]
            moodsByPhase       = [:]
            return
        }

        let earliest = allCycles[0].startDate
        let latest   = allCycles.last?.endDate ?? Date()
        let allLogs  = cycleRepository.fetchDailyLogs(from: earliest, to: latest)
            .sorted { $0.date < $1.date }
        dailyLogs = allLogs

        // ----------------------------------------------------------------
        // 6. Aggregate symptom frequencies
        // ----------------------------------------------------------------
        var symptomCounts: [Symptom: Int] = [:]
        for log in allLogs {
            for symptom in log.symptoms {
                symptomCounts[symptom, default: 0] += 1
            }
        }
        symptomFrequencies = symptomCounts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { (symptom: $0.key, count: $0.value) }

        // ----------------------------------------------------------------
        // 7. Aggregate mood frequencies
        // ----------------------------------------------------------------
        var moodCounts: [Mood: Int] = [:]
        for log in allLogs {
            for mood in log.moods {
                moodCounts[mood, default: 0] += 1
            }
        }
        moodFrequencies = moodCounts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { (mood: $0.key, count: $0.value) }

        // ----------------------------------------------------------------
        // 8. Phase-grouped analytics
        //    Map each log's date to a cycle phase using the prediction.
        // ----------------------------------------------------------------
        var symptomPhaseMap: [CyclePhase: [Symptom: Int]] = [:]
        var moodPhaseMap: [CyclePhase: [Mood: Int]] = [:]

        // Initialise all phases so views never get nil dictionaries
        for phase in CyclePhase.allCases {
            symptomPhaseMap[phase] = [:]
            moodPhaseMap[phase]    = [:]
        }

        for log in allLogs {
            guard let phase = phaseForLog(log, cycles: allCycles) else { continue }
            for symptom in log.symptoms {
                symptomPhaseMap[phase, default: [:]][symptom, default: 0] += 1
            }
            for mood in log.moods {
                moodPhaseMap[phase, default: [:]][mood, default: 0] += 1
            }
        }

        symptomsByPhase = symptomPhaseMap
        moodsByPhase    = moodPhaseMap
    }

    // MARK: - Chart Data

    /// Returns the indexed cycle-length pairs ready for Swift Charts consumption.
    ///
    /// Each element carries an `index` (1-based, for the X axis) and the
    /// `length` in days (for the Y axis).
    func cycleLengthChartData() -> [(index: Int, length: Int)] {
        cycleLengths.enumerated().map { (index: $0.offset + 1, length: $0.element.length) }
    }

    // MARK: - Private Helpers

    /// Maps a daily log to the cycle phase it fell within, using the nearest
    /// preceding cycle entry and the stored or predicted cycle length.
    ///
    /// Returns `nil` when there is no preceding cycle to anchor on.
    private func phaseForLog(_ log: DailyLog, cycles: [CycleEntry]) -> CyclePhase? {
        // Find the most-recent cycle whose startDate is on or before the log date.
        let logDay = Calendar.current.startOfDay(for: log.date)
        guard let containingCycle = cycles
            .filter({ Calendar.current.startOfDay(for: $0.startDate) <= logDay })
            .last
        else { return nil }

        // Use the stored cycle length when available, otherwise fall back to the
        // average or the default.
        let cycleLen: Int
        if let stored = containingCycle.cycleLengthDays, stored > 0 {
            cycleLen = stored
        } else {
            cycleLen = averageCycleLength > 0
                ? averageCycleLength
                : Constants.Cycle.defaultLength
        }

        // Day within cycle (1-based)
        let daysDiff = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: containingCycle.startDate),
            to:   logDay
        ).day ?? 0
        let day = daysDiff + 1

        // Derive a minimal prediction to reuse the phase algorithm.
        // We only need predictedPeriodLength and predictedCycleLength.
        let periodLen = Constants.Cycle.defaultPeriodLength
        let ovulationDay = cycleLen - Constants.Cycle.lutealPhaseLength

        switch day {
        case 1...periodLen:
            return .menstrual
        case (periodLen + 1)...(ovulationDay - 2):
            return .follicular
        case (ovulationDay - 1)...(ovulationDay + 1):
            return .ovulation
        default:
            return .luteal
        }
    }
}
