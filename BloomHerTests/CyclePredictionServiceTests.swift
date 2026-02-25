//
//  CyclePredictionServiceTests.swift
//  BloomHerTests
//
//  Tests for the weighted-moving-average cycle prediction algorithm.
//  Covers the full surface of CyclePredictionService including confidence
//  assignment, irregularity detection, fertile-window widening, phase
//  classification, cycle-day arithmetic, and plausibility clamping.
//

import XCTest
@testable import BloomHer

final class CyclePredictionServiceTests: XCTestCase {

    // MARK: - Subject Under Test

    private var service: CyclePredictionService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        service = CyclePredictionService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - No Cycles

    func testPredictionWithNoCycles() {
        // When no history exists the service must return a safe default anchored
        // to today with a 28-day cycle length and low confidence.
        let prediction = service.predictNextPeriod(from: [])

        XCTAssertEqual(
            prediction.predictedCycleLength,
            Constants.Cycle.defaultLength,
            "Empty history should produce the default cycle length of \(Constants.Cycle.defaultLength) days."
        )
        XCTAssertEqual(
            prediction.predictedPeriodLength,
            Constants.Cycle.defaultPeriodLength,
            "Empty history should produce the default period length of \(Constants.Cycle.defaultPeriodLength) days."
        )
        XCTAssertEqual(
            prediction.confidence,
            .low,
            "No cycle data should yield low confidence."
        )
        XCTAssertFalse(
            prediction.isIrregular,
            "No cycle data should not be flagged as irregular."
        )
    }

    // MARK: - Single Cycle

    func testPredictionWithSingleCycle() {
        // A single cycle entry provides a start date but cannot produce a measured
        // cycle length (we need two start dates for that). The service should fall
        // back to the default length with low confidence.
        let cycles = [makeCycle(start: date(2025, 1, 1))]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.predictedCycleLength,
            Constants.Cycle.defaultLength,
            "A single recorded cycle should still use the default length."
        )
        XCTAssertEqual(
            prediction.confidence,
            .low,
            "A single recorded cycle should yield low confidence."
        )
    }

    // MARK: - Two Cycles (below minimum threshold)

    func testPredictionWithTwoCycles() {
        // Two cycles give one derived length — still below minCyclesForPrediction (3).
        // Expect default length and low confidence.
        let cycles = [
            makeCycle(start: date(2025, 1, 1)),
            makeCycle(start: date(2025, 1, 29)) // 28-day gap
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.predictedCycleLength,
            Constants.Cycle.defaultLength,
            "Two cycles (one derived length) should still fall back to the default because minCyclesForPrediction is \(Constants.Cycle.minCyclesForPrediction)."
        )
        XCTAssertEqual(
            prediction.confidence,
            .low,
            "Two cycles should yield low confidence (below minimum threshold)."
        )
    }

    // MARK: - Three Cycles (meets minimum threshold)

    func testPredictionWithThreeCycles() {
        // Three cycles → two derived lengths → meets minCyclesForPrediction.
        // Expect medium confidence and a valid (non-default-forced) prediction.
        let cycles = [
            makeCycle(start: date(2025, 1, 1)),
            makeCycle(start: date(2025, 1, 29)), // 28 days
            makeCycle(start: date(2025, 2, 26))  // 28 days
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.predictedCycleLength,
            28,
            "Three identical 28-day cycles should predict a 28-day cycle."
        )
        XCTAssertEqual(
            prediction.confidence,
            .medium,
            "Three regular cycles should yield medium confidence."
        )
        XCTAssertFalse(
            prediction.isIrregular,
            "Three identical cycle lengths should not be flagged as irregular."
        )
    }

    // MARK: - Six Regular Cycles (high confidence)

    func testPredictionWithSixRegularCycles() {
        // Six cycles → five derived lengths → qualifies for high confidence when regular.
        let cycles = makeSixRegularCycles(length: 28, startingFrom: date(2024, 7, 1))
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.predictedCycleLength,
            28,
            "Six regular 28-day cycles should predict exactly 28 days."
        )
        XCTAssertEqual(
            prediction.confidence,
            .high,
            "Six regular cycles should yield high confidence."
        )
        XCTAssertFalse(
            prediction.isIrregular,
            "Six identical cycle lengths should not be flagged as irregular."
        )
    }

    // MARK: - Weighted Mean Favours Recent Cycles

    func testWeightedMeanFavorsRecentCycles() {
        // Build a history where old cycles are 21 days and the three most recent
        // are 35 days. The WMA should skew the prediction toward 35 days, making
        // it higher than the arithmetic mean of the full series.
        let cycles = [
            makeCycle(start: date(2024, 1, 1)),
            makeCycle(start: date(2024, 1, 22)),  // 21-day gap (old)
            makeCycle(start: date(2024, 2, 12)),  // 21-day gap (old)
            makeCycle(start: date(2024, 3, 4)),   // 20-day gap (old, rounded)
            makeCycle(start: date(2024, 4, 8)),   // 35-day gap (recent)
            makeCycle(start: date(2024, 5, 13)),  // 35-day gap (recent)
            makeCycle(start: date(2024, 6, 17))   // 35-day gap (recent)
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        // Arithmetic mean of [21, 21, 20, 35, 35, 35] ≈ 27.8 days.
        // The WMA should push the result above 28 because the three 35-day
        // cycles are the most-recent and carry the highest weights.
        XCTAssertGreaterThan(
            prediction.predictedCycleLength,
            27,
            "WMA should skew the prediction toward the more-recent longer cycles."
        )
    }

    // MARK: - Irregular Cycle Detection

    func testIrregularCycleDetection() {
        // Cycles with high coefficient of variation should be flagged as irregular.
        // Using 21, 35, 22, 40, 20 days — mean ≈ 27.6, stddev ≈ 8.1, CV ≈ 0.29 > 0.15.
        let cycles = [
            makeCycle(start: date(2024, 1, 1)),
            makeCycle(start: date(2024, 1, 22)),  // 21 days
            makeCycle(start: date(2024, 2, 26)),  // 35 days
            makeCycle(start: date(2024, 3, 19)),  // 22 days
            makeCycle(start: date(2024, 4, 28)),  // 40 days
            makeCycle(start: date(2024, 5, 18))   // 20 days
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertTrue(
            prediction.isIrregular,
            "Cycles with CV above \(Constants.Cycle.irregularCVThreshold) should be flagged as irregular."
        )
        XCTAssertNotEqual(
            prediction.confidence,
            .high,
            "Irregular cycles must never produce high confidence."
        )
    }

    func testIsIrregular_protocol() {
        let irregularCycles = [
            makeCycle(start: date(2024, 1, 1)),
            makeCycle(start: date(2024, 1, 22)),  // 21
            makeCycle(start: date(2024, 2, 26)),  // 35
            makeCycle(start: date(2024, 3, 19)),  // 22
            makeCycle(start: date(2024, 4, 28))   // 40
        ]
        XCTAssertTrue(
            service.isIrregular(cycles: irregularCycles),
            "isIrregular(cycles:) should return true for high-CV input."
        )

        let regularCycles = [
            makeCycle(start: date(2024, 1, 1)),
            makeCycle(start: date(2024, 1, 29)),
            makeCycle(start: date(2024, 2, 26)),
            makeCycle(start: date(2024, 3, 25))
        ]
        XCTAssertFalse(
            service.isIrregular(cycles: regularCycles),
            "isIrregular(cycles:) should return false for stable-CV input."
        )
    }

    // MARK: - Fertile Window

    func testFertileWindowCalculation() {
        // For a regular 28-day cycle with minCycles met:
        //   ovulation day = 28 - 14 = day 14 of the cycle
        //   window = [ovulation - 5, ovulation] = 6 days total
        let cycles = [
            makeCycle(start: date(2024, 1, 1)),
            makeCycle(start: date(2024, 1, 29)),  // 28 days
            makeCycle(start: date(2024, 2, 26)),  // 28 days
            makeCycle(start: date(2024, 3, 25))   // 28 days
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        let windowDays = Calendar.current.dateComponents(
            [.day],
            from: prediction.fertileWindowStart,
            to: prediction.fertileWindowEnd
        ).day ?? -1

        XCTAssertEqual(
            windowDays,
            Constants.Cycle.fertileWindowDays - 1, // interval endpoints inclusive = 5 days span
            "Standard fertile window should span \(Constants.Cycle.fertileWindowDays - 1) days (6-day inclusive range)."
        )
        XCTAssertLessThanOrEqual(
            prediction.fertileWindowStart,
            prediction.fertileWindowEnd,
            "Fertile window start must not be after its end."
        )
    }

    func testFertileWindowWidenedForIrregular() {
        // For irregular cycles the fertile window is widened by ±2 days,
        // so the span becomes (fertileWindowDays - 1 + 4) = 9 days.
        let cycles = [
            makeCycle(start: date(2024, 1, 1)),
            makeCycle(start: date(2024, 1, 22)),  // 21
            makeCycle(start: date(2024, 2, 26)),  // 35
            makeCycle(start: date(2024, 3, 19)),  // 22
            makeCycle(start: date(2024, 4, 28)),  // 40
            makeCycle(start: date(2024, 5, 18))   // 20
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertTrue(
            prediction.isIrregular,
            "Prerequisite: these cycles must be flagged irregular for the widening test to be meaningful."
        )

        let windowDays = Calendar.current.dateComponents(
            [.day],
            from: prediction.fertileWindowStart,
            to: prediction.fertileWindowEnd
        ).day ?? -1

        // Standard span = 5 days; widened by +2 on each side = 9 days span.
        let expectedSpan = (Constants.Cycle.fertileWindowDays - 1) + 4
        XCTAssertEqual(
            windowDays,
            expectedSpan,
            "Irregular cycle fertile window should be widened by ±2 days (span = \(expectedSpan))."
        )
    }

    func testFertileWindow_returnsNilForLowConfidenceRegular() {
        // When confidence is low and cycle is not irregular, fertileWindow() must
        // return nil because there is insufficient data to show a reliable window.
        let cycles = [makeCycle(start: date(2025, 1, 1))]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(prediction.confidence, .low, "Prerequisite: single-cycle prediction must be low confidence.")
        XCTAssertFalse(prediction.isIrregular, "Prerequisite: single-cycle prediction must not be irregular.")
        XCTAssertNil(
            service.fertileWindow(prediction: prediction),
            "fertileWindow() must return nil for low-confidence regular predictions."
        )
    }

    func testFertileWindow_returnsIntervalForMediumConfidence() {
        let cycles = [
            makeCycle(start: date(2025, 1, 1)),
            makeCycle(start: date(2025, 1, 29)),
            makeCycle(start: date(2025, 2, 26)),
            makeCycle(start: date(2025, 3, 26))
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertNotNil(
            service.fertileWindow(prediction: prediction),
            "fertileWindow() must return a DateInterval for medium-confidence predictions."
        )
    }

    // MARK: - Cycle Day Calculation

    func testCycleDayCalculation() {
        // Start date is today — should be day 1.
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(
            service.cycleDay(from: today),
            1,
            "Cycle day should be 1 when the start date is today."
        )
    }

    func testCycleDayCalculation_sevenDaysAgo() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!
        XCTAssertEqual(
            service.cycleDay(from: sevenDaysAgo),
            7,
            "Cycle day should be 7 when start was 6 days ago."
        )
    }

    func testCycleDayCalculation_twentyEightDaysAgo() {
        let start = Calendar.current.date(byAdding: .day, value: -27, to: Calendar.current.startOfDay(for: Date()))!
        XCTAssertEqual(
            service.cycleDay(from: start),
            28,
            "Cycle day should be 28 when start was 27 days ago."
        )
    }

    func testCycleDayCalculation_futureDateClampedToOne() {
        // If the period start is in the future (e.g. a data entry error), day must
        // be at least 1 — never 0 or negative.
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertGreaterThanOrEqual(
            service.cycleDay(from: tomorrow),
            1,
            "cycleDay must always return at least 1, even for future start dates."
        )
    }

    // MARK: - Days Late

    func testDaysLateWhenNotLate() {
        // Next period is in the future — daysLate must be nil.
        let futureStart = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let prediction = makePrediction(nextStart: futureStart)

        XCTAssertNil(
            service.daysLate(prediction: prediction),
            "daysLate() must return nil when the predicted start is in the future."
        )
    }

    func testDaysLateWhenLate() {
        // Predicted start was 3 days ago — daysLate must be 3.
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Calendar.current.startOfDay(for: Date()))!
        let prediction = makePrediction(nextStart: threeDaysAgo)

        XCTAssertEqual(
            service.daysLate(prediction: prediction),
            3,
            "daysLate() must return 3 when the predicted start was 3 days ago."
        )
    }

    func testDaysLateWhenOnExpectedDay() {
        // Predicted start is today — not yet late, so daysLate must be nil.
        let todayStart = Calendar.current.startOfDay(for: Date())
        let prediction = makePrediction(nextStart: todayStart)

        XCTAssertNil(
            service.daysLate(prediction: prediction),
            "daysLate() must return nil when the predicted start is exactly today."
        )
    }

    // MARK: - Current Phase

    func testCurrentPhase_menstrual() {
        // Day 1 of cycle should always be in the menstrual phase.
        let today = Calendar.current.startOfDay(for: Date())
        let prediction = makePrediction(cycleLength: 28, periodLength: 5)

        let phase = service.currentPhase(lastPeriodStart: today, prediction: prediction)
        XCTAssertEqual(
            phase,
            .menstrual,
            "Day 1 of cycle should be in the menstrual phase."
        )
    }

    func testCurrentPhase_follicular() {
        // Day 7 (after default 5-day period, before ovulation window day 13) = follicular.
        let sixDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!
        let prediction = makePrediction(cycleLength: 28, periodLength: 5)

        let phase = service.currentPhase(lastPeriodStart: sixDaysAgo, prediction: prediction)
        XCTAssertEqual(
            phase,
            .follicular,
            "Cycle day 7 (after menstrual, before ovulation window) should be follicular."
        )
    }

    func testCurrentPhase_ovulation() {
        // Ovulation day = cycleLength - lutealPhaseLength = 28 - 14 = day 14.
        // Day 13 falls in the ovulation window (ovulationDay - 1).
        let thirteenDaysAgo = Calendar.current.date(byAdding: .day, value: -13, to: Calendar.current.startOfDay(for: Date()))!
        let prediction = makePrediction(cycleLength: 28, periodLength: 5)

        let phase = service.currentPhase(lastPeriodStart: thirteenDaysAgo, prediction: prediction)
        XCTAssertEqual(
            phase,
            .ovulation,
            "Cycle day 14 (ovulationDay - 1 window) should be in the ovulation phase."
        )
    }

    func testCurrentPhase_luteal() {
        // Day 16 is past ovulation+1 day, so it must be in the luteal phase.
        let fifteenDaysAgo = Calendar.current.date(byAdding: .day, value: -15, to: Calendar.current.startOfDay(for: Date()))!
        let prediction = makePrediction(cycleLength: 28, periodLength: 5)

        let phase = service.currentPhase(lastPeriodStart: fifteenDaysAgo, prediction: prediction)
        XCTAssertEqual(
            phase,
            .luteal,
            "Cycle day 16 (past ovulation window) should be in the luteal phase."
        )
    }

    // MARK: - Plausibility Clamping

    func testImplausiblyShortCycleIgnored() {
        // A gap of 8 days between two start dates is below the 10-day sanity floor
        // and must be silently ignored. With only one valid derived length, the
        // prediction falls back to the default.
        let cycles = [
            makeCycle(start: date(2025, 1, 1)),
            makeCycle(start: date(2025, 1, 9)),  // 8 days — implausibly short, ignored
            makeCycle(start: date(2025, 2, 6))   // 28 days from first entry
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        // Only one valid cycle length derived, so still below minCyclesForPrediction.
        XCTAssertEqual(
            prediction.predictedCycleLength,
            Constants.Cycle.defaultLength,
            "An implausibly short cycle (<10 days) should be ignored, keeping us below the minimum threshold."
        )
    }

    func testImplausiblyLongCycleIgnored() {
        // A gap of 90 days exceeds the 60-day sanity ceiling and must be ignored.
        let cycles = [
            makeCycle(start: date(2025, 1, 1)),
            makeCycle(start: date(2025, 4, 1)),  // 90 days — implausibly long, ignored
            makeCycle(start: date(2025, 4, 29))  // 28 days from second entry — also ignored (second gap is fine but first pair uses it)
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        // Only one valid cycle length (28) survives — still below minimum.
        XCTAssertEqual(
            prediction.predictedCycleLength,
            Constants.Cycle.defaultLength,
            "An implausibly long cycle (>60 days) should be ignored, keeping us below the minimum threshold."
        )
    }

    func testValidCyclesAroundBoundary() {
        // Exactly 10-day and 60-day cycles sit on the valid boundary and must be kept.
        let cycles = [
            makeCycle(start: date(2025, 1, 1)),
            makeCycle(start: date(2025, 1, 11)),  // 10 days — valid lower bound
            makeCycle(start: date(2025, 3, 12)),  // 60 days — valid upper bound
            makeCycle(start: date(2025, 3, 22))   // 10 days — valid
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        // Three valid derived lengths [10, 60, 10] meets minCyclesForPrediction.
        // Prediction should not fall back to default 28.
        XCTAssertNotEqual(
            prediction.confidence,
            .low,
            "Three cycles that sit on the valid boundary should all be accepted and yield at least medium confidence."
        )
    }

    // MARK: - Predicted Next Start

    func testPredictedNextStart_isInFuture() {
        // For a recent cycle, the predicted next start should generally be in
        // the near future unless the cycle is extremely long.
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let cycles = [
            makeCycle(start: Calendar.current.date(byAdding: .day, value: -58, to: Date())!),
            makeCycle(start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!),
            makeCycle(start: thirtyDaysAgo)
        ]
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertNotNil(
            prediction.predictedNextStart,
            "predictedNextStart should always be populated."
        )
    }

    // MARK: - Private Helpers

    /// Creates a `CycleEntry` with the supplied start and optional end dates.
    private func makeCycle(start: Date, end: Date? = nil) -> CycleEntry {
        let entry = CycleEntry(startDate: start, isConfirmed: true)
        entry.endDate = end
        return entry
    }

    /// Builds a `Date` from year, month, day components in the current calendar.
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year  = year
        components.month = month
        components.day   = day
        return Calendar.current.date(from: components)!
    }

    /// Builds `n` cycles of equal `length` starting from `startingFrom`.
    private func makeSixRegularCycles(length: Int, startingFrom start: Date) -> [CycleEntry] {
        var cycles: [CycleEntry] = []
        var current = start
        for _ in 0...5 {
            cycles.append(makeCycle(start: current))
            current = Calendar.current.date(byAdding: .day, value: length, to: current)!
        }
        return cycles
    }

    /// Creates a `CyclePrediction` with a specific next-start date for daysLate testing.
    private func makePrediction(nextStart: Date) -> CyclePrediction {
        CyclePrediction(
            predictedNextStart:    nextStart,
            predictedPeriodLength: Constants.Cycle.defaultPeriodLength,
            predictedCycleLength:  Constants.Cycle.defaultLength,
            estimatedOvulationDate: nextStart,
            fertileWindowStart:    nextStart,
            fertileWindowEnd:      nextStart,
            confidence:            .medium,
            isIrregular:           false
        )
    }

    /// Creates a `CyclePrediction` with specific cycle and period lengths for phase testing.
    private func makePrediction(cycleLength: Int, periodLength: Int) -> CyclePrediction {
        let today = Calendar.current.startOfDay(for: Date())
        let nextStart = Calendar.current.date(byAdding: .day, value: cycleLength, to: today)!
        return CyclePrediction(
            predictedNextStart:    nextStart,
            predictedPeriodLength: periodLength,
            predictedCycleLength:  cycleLength,
            estimatedOvulationDate: nextStart,
            fertileWindowStart:    nextStart,
            fertileWindowEnd:      nextStart,
            confidence:            .medium,
            isIrregular:           false
        )
    }
}
