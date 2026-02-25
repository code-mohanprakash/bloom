//
//  TTCViewModel.swift
//  BloomHer
//
//  Observable view-model for the Trying-To-Conceive feature set.
//  Owns OPK result loading, BBT entry loading, cycle prediction access,
//  and the derived fertile-window state exposed to all TTC views.
//

import Foundation
import Observation
import SwiftUI

// MARK: - TTCViewModel

/// The single source of truth for all TTC feature screens.
///
/// Marked `@MainActor` so every property mutation is safe to drive SwiftUI
/// from — no manual `DispatchQueue.main.async` wrappers are needed in views.
@Observable
@MainActor
final class TTCViewModel {

    // MARK: - Dependencies

    private let ttcRepository: TTCRepositoryProtocol
    private let cycleRepository: CycleRepositoryProtocol
    private let predictionService: CyclePredictorProtocol

    // MARK: - Fertile-Window State

    /// The full cycle prediction, or `nil` when fewer than one cycle has been logged.
    var prediction: CyclePrediction?

    /// Convenience: fertile window start date from the current prediction.
    var fertileWindowStart: Date? { prediction?.fertileWindowStart }

    /// Convenience: fertile window end date from the current prediction.
    var fertileWindowEnd: Date? { prediction?.fertileWindowEnd }

    /// The estimated ovulation date from the current prediction.
    var estimatedOvulationDate: Date? { prediction?.estimatedOvulationDate }

    /// Calendar days until the fertile window opens.  0 when inside, negative
    /// when the window has already passed for this cycle.
    var daysUntilFertileWindow: Int {
        guard let start = fertileWindowStart else { return Int.max }
        let today = Calendar.current.startOfDay(for: Date())
        let windowStart = Calendar.current.startOfDay(for: start)
        return Calendar.current.dateComponents([.day], from: today, to: windowStart).day ?? 0
    }

    /// `true` when today falls within the predicted fertile window.
    var isInFertileWindow: Bool {
        guard let start = fertileWindowStart, let end = fertileWindowEnd else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let windowStart = Calendar.current.startOfDay(for: start)
        let windowEnd = Calendar.current.startOfDay(for: end)
        return today >= windowStart && today <= windowEnd
    }

    /// `true` when today is on or past the estimated ovulation day.
    var isOvulationDay: Bool {
        guard let ovDate = estimatedOvulationDate else { return false }
        return Calendar.current.isDateInToday(ovDate)
    }

    // MARK: - OPK State

    /// The most-recent 30 days of OPK results, sorted oldest-to-newest.
    var recentOPKResults: [OPKResult] = []

    /// Pattern inference based on recent results.
    var opkTrend: OPKTrend {
        let last3 = recentOPKResults.suffix(3).map(\.result)
        if last3.contains(.positive) { return .positive }
        if last3.filter({ $0 == .faint }).count >= 2 { return .rising }
        return .stable
    }

    // MARK: - BBT State

    /// The most-recent 30 days of BBT readings, sorted oldest-to-newest.
    var recentBBTEntries: [BBTEntry] = []

    /// Approximate coverline: average of the lowest third of recent temps.
    var coverlineTemperature: Double? {
        guard recentBBTEntries.count >= 6 else { return nil }
        let sorted = recentBBTEntries.map(\.temperatureCelsius).sorted()
        let lowerThird = sorted.prefix(sorted.count / 3 + 1)
        return lowerThird.reduce(0, +) / Double(lowerThird.count)
    }

    /// `true` when a thermal shift has been detected (3 temps above coverline).
    var hasThermalShift: Bool {
        guard let coverline = coverlineTemperature else { return false }
        let last6 = recentBBTEntries.suffix(6).map(\.temperatureCelsius)
        let aboveCoverline = last6.filter { $0 > coverline + 0.2 }
        return aboveCoverline.count >= 3
    }

    // MARK: - Cycle Attempt Counter

    /// How many full cycles have been logged (proxy for "cycles trying").
    var cycleCount: Int = 0

    // MARK: - Current Phase

    /// The current cycle phase derived from the active prediction.
    var currentPhase: CyclePhase {
        guard
            let prediction,
            let activeCycle = cycleRepository.fetchActiveCycle()
        else { return .follicular }
        return predictionService.currentPhase(
            lastPeriodStart: activeCycle.startDate,
            prediction: prediction
        )
    }

    // MARK: - Loading State

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.ttcRepository     = dependencies.ttcRepository
        self.cycleRepository   = dependencies.cycleRepository
        self.predictionService = dependencies.cyclePredictionService
    }

    // MARK: - Public API

    /// Refreshes all TTC data from the repository.
    func refresh() {
        isLoading = true
        errorMessage = nil
        let cycles = cycleRepository.fetchAllCycles()
        cycleCount = max(0, cycles.count - 1)
        if cycles.count >= 1 {
            let basePrediction = predictionService.predictNextPeriod(from: cycles)
            prediction = predictionWithPositiveOPKOverride(
                basePrediction: basePrediction,
                cycles: cycles
            )
        }
        loadOPKResults()
        loadBBTEntries()
        isLoading = false
    }

    /// Loads OPK results for the past 30 days.
    func loadOPKResults() {
        let end   = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
        recentOPKResults = ttcRepository.fetchOPKResults(from: start, to: end)
    }

    /// Loads BBT entries for the past 30 days.
    func loadBBTEntries() {
        let end   = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
        recentBBTEntries = ttcRepository.fetchBBTEntries(from: start, to: end)
    }

    /// Saves a new OPK result and refreshes the local cache.
    func saveOPK(date: Date, level: OPKLevel) {
        let result = OPKResult(date: date, result: level)
        ttcRepository.saveOPKResult(result)
        BloomHerTheme.Haptics.success()
        refresh()
    }

    /// Saves a new BBT entry and refreshes the local cache.
    func saveBBT(date: Date, temperature: Double) {
        guard temperature > 30 && temperature < 42 else {
            errorMessage = "Please enter a temperature between 30 and 42 °C."
            BloomHerTheme.Haptics.error()
            return
        }
        let entry = BBTEntry(date: date, temperatureCelsius: temperature)
        ttcRepository.saveBBTEntry(entry)
        BloomHerTheme.Haptics.success()
        loadBBTEntries()
    }

    // MARK: - Prediction Overrides

    private func predictionWithPositiveOPKOverride(
        basePrediction: CyclePrediction,
        cycles: [CycleEntry]
    ) -> CyclePrediction {
        guard
            let currentCycleStart = cycles
                .map(\.startDate)
                .max(),
            let latestPositive = ttcRepository.fetchLatestPositiveOPK(from: currentCycleStart)
        else {
            return basePrediction
        }

        let ovulationOverride = Calendar.current.startOfDay(for: latestPositive.date)
        let cycleEnd = Calendar.current.startOfDay(for: basePrediction.predictedNextStart)

        // Ignore stale positives that are likely from an earlier cycle.
        guard ovulationOverride <= cycleEnd else { return basePrediction }

        let fertileStart = Calendar.current.date(
            byAdding: .day,
            value: -(Constants.Cycle.fertileWindowDays - 1),
            to: ovulationOverride
        ) ?? ovulationOverride

        return CyclePrediction(
            predictedNextStart: basePrediction.predictedNextStart,
            predictedPeriodLength: basePrediction.predictedPeriodLength,
            predictedCycleLength: basePrediction.predictedCycleLength,
            estimatedOvulationDate: ovulationOverride,
            fertileWindowStart: fertileStart,
            fertileWindowEnd: ovulationOverride,
            confidence: basePrediction.confidence,
            isIrregular: basePrediction.isIrregular
        )
    }
}

// MARK: - OPKTrend

/// Describes the directional trend of recent OPK readings.
enum OPKTrend {
    case stable
    case rising
    case positive

    var displayMessage: String {
        switch self {
        case .stable:   return "No strong LH surge detected yet."
        case .rising:   return "Your OPK is trending positive — keep testing!"
        case .positive: return "Positive OPK! Ovulation is likely within 24–36 hours."
        }
    }

    var icon: String {
        switch self {
        case .stable:   return "minus-circle"
        case .rising:   return "arrow-up-circle"
        case .positive: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .stable:   return BloomHerTheme.Colors.textSecondary
        case .rising:   return BloomHerTheme.Colors.accentPeach
        case .positive: return BloomHerTheme.Colors.sageGreen
        }
    }
}
