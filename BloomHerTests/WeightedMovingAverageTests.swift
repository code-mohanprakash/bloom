//
//  WeightedMovingAverageTests.swift
//  BloomHerTests
//
//  Focused verification of the weighted-moving-average (WMA) mathematics
//  embedded in CyclePredictionService.
//
//  Because the WMA helpers are private, all assertions are made through
//  the public `predictNextPeriod(from:)` entry point and the
//  `predictedCycleLength` property of the returned `CyclePrediction`.
//
//  Decay factor: 0.85  (Constants.Cycle.weightDecayFactor)
//  Weight scheme: oldest element → 0.85^(n-1), newest element → 0.85^0 = 1.0
//

import XCTest
@testable import BloomHer

final class WeightedMovingAverageTests: XCTestCase {

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

    // MARK: - Equal Lengths (degenerate case)

    func testEqualLengthsCycles() {
        // When every derived cycle length is the same, the WMA must equal that length
        // regardless of the weights applied.
        // Derived lengths: [28, 28, 28, 28, 28]
        let cycles = buildCycles(lengths: [28, 28, 28, 28, 28])
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.predictedCycleLength,
            28,
            "WMA of five identical 28-day lengths must equal 28."
        )
    }

    // MARK: - Decreasing Lengths (oldest long, newest short)

    func testDecreasingLengths() {
        // Derived lengths oldest→newest: [35, 30, 25].
        // Weights: [0.85^2, 0.85^1, 0.85^0] = [0.7225, 0.85, 1.0]
        // Weighted sum  = 35*0.7225 + 30*0.85 + 25*1.0
        //               = 25.2875   + 25.5    + 25.0   = 75.7875
        // Total weight  = 0.7225 + 0.85 + 1.0           = 2.5725
        // WMA           ≈ 75.7875 / 2.5725              ≈ 29.46 → rounds to 29
        let cycles = buildCycles(lengths: [35, 30, 25])
        let prediction = service.predictNextPeriod(from: cycles)

        // Arithmetic mean would be (35+30+25)/3 = 30.
        // WMA should be below 30 because the shortest (most-recent) cycle has the highest weight.
        XCTAssertLessThan(
            prediction.predictedCycleLength,
            30,
            "When recent cycles are shorter, WMA must be below the arithmetic mean."
        )
        XCTAssertEqual(
            prediction.predictedCycleLength,
            29,
            "WMA of [35, 30, 25] with 0.85 decay should round to 29."
        )
    }

    // MARK: - Increasing Lengths (oldest short, newest long)

    func testIncreasingLengths() {
        // Derived lengths oldest→newest: [25, 30, 35].
        // Weights: [0.7225, 0.85, 1.0]
        // Weighted sum  = 25*0.7225 + 30*0.85 + 35*1.0
        //               = 18.0625   + 25.5    + 35.0   = 78.5625
        // Total weight  = 2.5725
        // WMA           ≈ 78.5625 / 2.5725              ≈ 30.54 → rounds to 31
        let cycles = buildCycles(lengths: [25, 30, 35])
        let prediction = service.predictNextPeriod(from: cycles)

        // Arithmetic mean = 30. WMA must be above 30 because the longest cycle is most-recent.
        XCTAssertGreaterThan(
            prediction.predictedCycleLength,
            30,
            "When recent cycles are longer, WMA must be above the arithmetic mean."
        )
        XCTAssertEqual(
            prediction.predictedCycleLength,
            31,
            "WMA of [25, 30, 35] with 0.85 decay should round to 31."
        )
    }

    // MARK: - Single Extreme Outlier

    func testSingleExtremeOutlier() {
        // An old outlier (50 days) among otherwise stable 28-day cycles should
        // have reduced impact on the WMA compared to an arithmetic mean.
        //
        // Derived lengths oldest→newest: [50, 28, 28, 28].
        // Weights: [0.85^3, 0.85^2, 0.85^1, 0.85^0] = [0.614125, 0.7225, 0.85, 1.0]
        // Weighted sum  = 50*0.614125 + 28*0.7225 + 28*0.85 + 28*1.0
        //               = 30.70625   + 20.23     + 23.8    + 28.0   = 102.73625
        // Total weight  = 0.614125 + 0.7225 + 0.85 + 1.0            = 3.186625
        // WMA           ≈ 102.73625 / 3.186625                      ≈ 32.24 → rounds to 32
        //
        // Arithmetic mean = (50+28+28+28)/4 = 33.5 → rounds to 34.
        // WMA should be below the arithmetic mean because the outlier is oldest/least-weighted.
        let cycles = buildCycles(lengths: [50, 28, 28, 28])
        let prediction = service.predictNextPeriod(from: cycles)

        let arithmeticMean = (50 + 28 + 28 + 28) / 4  // = 33
        XCTAssertLessThan(
            prediction.predictedCycleLength,
            arithmeticMean + 1,  // WMA ≤ arithmetic mean
            "Old outlier should carry less weight, pulling the WMA below the arithmetic mean."
        )
        XCTAssertEqual(
            prediction.predictedCycleLength,
            32,
            "WMA of [50, 28, 28, 28] with 0.85 decay should round to 32."
        )
    }

    // MARK: - Decay Factor Effect

    func testDecayFactorEffect() {
        // Confirm the 0.85 decay factor is what the service actually uses by
        // validating a known-answer calculation.
        //
        // Derived lengths oldest→newest: [20, 28, 36].
        // Weights: [0.85^2, 0.85^1, 0.85^0] = [0.7225, 0.85, 1.0]
        // Weighted sum  = 20*0.7225 + 28*0.85 + 36*1.0
        //               = 14.45    + 23.8     + 36.0  = 74.25
        // Total weight  = 0.7225 + 0.85 + 1.0          = 2.5725
        // WMA           ≈ 74.25 / 2.5725               ≈ 28.86 → rounds to 29
        let cycles = buildCycles(lengths: [20, 28, 36])
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.predictedCycleLength,
            29,
            "Decay factor 0.85 applied to [20, 28, 36] must produce a WMA of ~28.86, rounding to 29."
        )
        XCTAssertEqual(
            Constants.Cycle.weightDecayFactor,
            0.85,
            "The decay factor constant must remain 0.85 for these known-answer tests to hold."
        )
    }

    // MARK: - Large History Window

    func testWindowClampsToMaxHistory() {
        // Build more cycles than maxHistoryForPrediction (12). The service must
        // silently ignore the oldest cycles.  Result should still be a valid
        // prediction — this is a smoke test to confirm no crash and valid output.
        var lengths = [Int](repeating: 28, count: 15) // 15 derived lengths → 16 cycle entries
        lengths[0] = 60  // This old outlier should be discarded (outside the 12-cycle window).
        lengths[1] = 60
        lengths[2] = 60

        let cycles = buildCycles(lengths: lengths)
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertGreaterThan(
            prediction.predictedCycleLength,
            0,
            "Prediction must always return a positive cycle length."
        )
        // With old outliers discarded, the windowed prediction should be close to 28.
        XCTAssertEqual(
            prediction.predictedCycleLength,
            28,
            "When history is clamped to maxHistoryForPrediction, the oldest outlier cycles are excluded."
        )
    }

    // MARK: - Confidence Boundary Conditions

    func testConfidenceBoundary_exactlyThreeDerivedLengths() {
        // 4 entries → 3 derived lengths → exactly minCyclesForPrediction.
        let cycles = buildCycles(lengths: [28, 28, 28])
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.confidence,
            .medium,
            "Exactly minCyclesForPrediction regular lengths should yield medium confidence."
        )
    }

    func testConfidenceBoundary_fiveDerivedLengths() {
        // 6 entries → 5 derived lengths → medium (not yet >= 6 for high confidence).
        let cycles = buildCycles(lengths: [28, 28, 28, 28, 28])
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.confidence,
            .medium,
            "Five regular derived lengths should yield medium confidence (high requires >= 6)."
        )
    }

    func testConfidenceBoundary_sixDerivedLengths() {
        // 7 entries → 6 derived lengths → qualifies for high when regular.
        let cycles = buildCycles(lengths: [28, 28, 28, 28, 28, 28])
        let prediction = service.predictNextPeriod(from: cycles)

        XCTAssertEqual(
            prediction.confidence,
            .high,
            "Six regular derived lengths should yield high confidence."
        )
    }

    // MARK: - Private Helpers

    /// Converts an array of cycle `lengths` (in days) into `CycleEntry` objects with
    /// consecutive start dates, oldest first.
    ///
    /// - Parameter lengths: The successive inter-cycle gaps in days.
    /// - Returns: An array of `n + 1` entries, where `n = lengths.count`.
    private func buildCycles(lengths: [Int]) -> [CycleEntry] {
        var entries: [CycleEntry] = []
        var components = DateComponents()
        components.year  = 2024
        components.month = 1
        components.day   = 1
        var current = Calendar.current.date(from: components)!

        entries.append(CycleEntry(startDate: current, isConfirmed: true))
        for gap in lengths {
            current = Calendar.current.date(byAdding: .day, value: gap, to: current)!
            entries.append(CycleEntry(startDate: current, isConfirmed: true))
        }
        return entries
    }
}
