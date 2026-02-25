//
//  CalendarViewModel.swift
//  BloomHer
//
//  Observable view-model for the full cycle calendar screen.
//  Owns month navigation, date selection, cycle-phase lookups, and
//  fertility/prediction helpers. All repository access goes through
//  the injected protocols so the view-model is testable in isolation.
//

import Foundation
import SwiftUI

// MARK: - CalendarViewModel

/// The `@Observable` view-model that drives `CycleCalendarView`.
///
/// Responsibilities:
/// - Generate the ordered array of dates for the current displayed month.
/// - Serve per-date phase, flow, fertile, predicted-period, and ovulation queries.
/// - Navigate forward/backward through months.
/// - Track which date the user has selected and whether the detail sheet is open.
@Observable
final class CalendarViewModel {

    // MARK: - Published State

    /// The month currently displayed in the calendar (anchored to the first of the month).
    var currentMonth: Date = Date()

    /// The date the user tapped — drives the `DayDetailSheet` presentation.
    var selectedDate: Date? = nil

    /// Controls whether the `DayDetailSheet` is presented.
    var showDayDetail: Bool = false

    // MARK: - Private Dependencies

    private let cycleRepository: CycleRepositoryProtocol
    private let predictionService: CyclePredictorProtocol

    // MARK: - Private Cache

    /// All confirmed cycle entries — refreshed lazily when the model changes.
    private var _cycleEntries: [CycleEntry] = []

    /// Cached daily logs for the visible month — keyed by start-of-day.
    private var _dailyLogs: [Date: DailyLog] = [:]

    // MARK: - Init

    init(cycleRepository: CycleRepositoryProtocol, predictionService: CyclePredictorProtocol) {
        self.cycleRepository = cycleRepository
        self.predictionService = predictionService
        refreshData()
    }

    // MARK: - Computed: Calendar Grid

    /// All dates that belong to the displayed month, sorted ascending.
    var daysInMonth: [Date] {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
            let days = Calendar.current.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day
        else { return [] }

        return (0..<days).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: monthInterval.start)
        }
    }

    /// A flat 42-element array (6 rows × 7 columns) that pads the month
    /// with leading and trailing `nil` values so the grid aligns to Monday.
    ///
    /// `nil` entries render as empty cells in `CycleCalendarView`.
    var calendarGridDates: [Date?] {
        let days = daysInMonth
        guard let firstDay = days.first else { return [] }

        // Weekday index — Monday = 0, Sunday = 6 (ISO week)
        let rawWeekday = Calendar.current.component(.weekday, from: firstDay)
        // Swift's Calendar: 1 = Sunday. Convert to Monday-based: Mon=0 … Sun=6
        let leadingSpaces = (rawWeekday + 5) % 7

        var grid: [Date?] = Array(repeating: nil, count: leadingSpaces)
        grid.append(contentsOf: days.map { Optional($0) })

        // Pad to a multiple of 7
        let remainder = grid.count % 7
        if remainder != 0 {
            grid.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
        }
        return grid
    }

    // MARK: - Computed: Prediction & Entries

    /// The current cycle prediction derived from all stored entries.
    var prediction: CyclePrediction {
        predictionService.predictNextPeriod(from: cycleEntries)
    }

    /// All stored `CycleEntry` records, sorted ascending by start date.
    var cycleEntries: [CycleEntry] {
        _cycleEntries
    }

    /// Daily logs for every date in the currently displayed month, keyed by start-of-day.
    var dailyLogs: [Date: DailyLog] {
        _dailyLogs
    }

    // MARK: - Per-Date Queries

    /// Returns the `CyclePhase` active on `date`, or `nil` if no cycle data is available.
    func phaseFor(date: Date) -> CyclePhase? {
        guard let lastEntry = latestCycleEntry(on: date) else { return nil }
        return predictionService.currentPhase(
            lastPeriodStart: lastEntry.startDate,
            prediction: prediction
        )
    }

    /// Returns the logged `FlowLevel` for `date`, or `nil` if none was recorded.
    func flowLevelFor(date: Date) -> FlowLevel? {
        dailyLogs[date.startOfDay]?.flowIntensity
    }

    /// Returns `true` if `date` falls within the predicted fertile window.
    func isFertile(date: Date) -> Bool {
        guard let window = predictionService.fertileWindow(prediction: prediction) else {
            return false
        }
        let d = date.startOfDay
        return d >= window.start.startOfDay && d <= window.end.startOfDay
    }

    /// Returns `true` if `date` falls within the predicted next period range.
    func isPredictedPeriod(date: Date) -> Bool {
        let nextStart = prediction.predictedNextStart.startOfDay
        let nextEnd = Calendar.current.date(
            byAdding: .day,
            value: prediction.predictedPeriodLength - 1,
            to: nextStart
        )?.startOfDay ?? nextStart
        let d = date.startOfDay
        return d >= nextStart && d <= nextEnd
    }

    /// Returns `true` if `date` is the estimated ovulation day.
    func isOvulationDay(date: Date) -> Bool {
        date.isSameDay(as: prediction.estimatedOvulationDate)
    }

    /// Returns `true` if `date` is the start of a confirmed period.
    func isPeriodStart(date: Date) -> Bool {
        cycleEntries.contains { $0.startDate.isSameDay(as: date) }
    }

    // MARK: - Actions

    /// Selects a calendar date and opens the day-detail sheet.
    func selectDate(_ date: Date) {
        selectedDate = date
        showDayDetail = true
    }

    /// Advances the calendar to the next month.
    func nextMonth() {
        BloomHerTheme.Haptics.light()
        withAnimation(BloomHerTheme.Animation.standard) {
            currentMonth = Calendar.current.date(
                byAdding: .month, value: 1, to: currentMonth
            ) ?? currentMonth
        }
        refreshMonthLogs()
    }

    /// Retreats the calendar to the previous month.
    func previousMonth() {
        BloomHerTheme.Haptics.light()
        withAnimation(BloomHerTheme.Animation.standard) {
            currentMonth = Calendar.current.date(
                byAdding: .month, value: -1, to: currentMonth
            ) ?? currentMonth
        }
        refreshMonthLogs()
    }

    /// Refreshes the view-model's data from the repository.
    ///
    /// Call this after external mutations to `CycleEntry` or `DailyLog` records
    /// to keep the calendar in sync.
    func refreshData() {
        _cycleEntries = cycleRepository.fetchAllCycles()
        refreshMonthLogs()
    }

    // MARK: - Private Helpers

    /// Reloads `_dailyLogs` for every day in `currentMonth`.
    private func refreshMonthLogs() {
        guard
            let interval = Calendar.current.dateInterval(of: .month, for: currentMonth)
        else { return }

        let logs = cycleRepository.fetchDailyLogs(
            from: interval.start,
            to: interval.end
        )
        _dailyLogs = Dictionary(
            uniqueKeysWithValues: logs.map { ($0.date.startOfDay, $0) }
        )
    }

    /// Returns the most-recent `CycleEntry` whose start date is on or before `date`.
    private func latestCycleEntry(on date: Date) -> CycleEntry? {
        let target = date.startOfDay
        return cycleEntries
            .filter { $0.startDate.startOfDay <= target }
            .max(by: { $0.startDate < $1.startDate })
    }
}
