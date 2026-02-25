//
//  HomeViewModelTests.swift
//  BloomHerTests
//
//  Tests for HomeViewModel.
//  Uses AppDependencies.preview() to obtain a fully-wired dependency graph
//  backed by an in-memory SwiftData store, so no production data is touched.
//

import XCTest
import SwiftData
@testable import BloomHer

@MainActor
final class HomeViewModelTests: XCTestCase {

    // MARK: - Dependencies

    private var dependencies: AppDependencies!
    private var viewModel: HomeViewModel!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        dependencies = AppDependencies.preview()
        viewModel    = HomeViewModel(dependencies: dependencies)
    }

    override func tearDown() {
        viewModel    = nil
        dependencies = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState_prediction() {
        XCTAssertNil(
            viewModel.prediction,
            "prediction must be nil before the first refresh() call."
        )
    }

    func testInitialState_cycleDay() {
        XCTAssertEqual(
            viewModel.cycleDay,
            1,
            "cycleDay should default to 1 before any data is loaded."
        )
    }

    func testInitialState_cycleLength() {
        XCTAssertEqual(
            viewModel.cycleLength,
            Constants.Cycle.defaultLength,
            "cycleLength should default to Constants.Cycle.defaultLength before refresh()."
        )
    }

    func testInitialState_waterIntake() {
        XCTAssertEqual(
            viewModel.waterIntake,
            0,
            "waterIntake should be 0 before any data is loaded."
        )
    }

    func testInitialState_daysLate() {
        XCTAssertNil(
            viewModel.daysLate,
            "daysLate should be nil in the initial state."
        )
    }

    func testInitialState_phase() {
        XCTAssertEqual(
            viewModel.currentPhase,
            .follicular,
            "currentPhase should default to .follicular before any data is loaded."
        )
    }

    func testInitialState_showFlags() {
        XCTAssertFalse(viewModel.showQuickLog, "showQuickLog should be false initially.")
        XCTAssertFalse(viewModel.showDayDetail, "showDayDetail should be false initially.")
        XCTAssertFalse(viewModel.isLoading,    "isLoading should be false initially.")
        XCTAssertNil(viewModel.errorMessage,   "errorMessage should be nil initially.")
    }

    // MARK: - Refresh with No Cycles

    func testRefreshWithNoCycles_usesDefaults() {
        // No CycleEntry records exist → refresh must apply sensible defaults.
        viewModel.refresh()

        XCTAssertNil(
            viewModel.prediction,
            "prediction must remain nil after refresh when no cycles exist."
        )
        XCTAssertEqual(
            viewModel.currentPhase,
            .follicular,
            "currentPhase must default to .follicular when no data is available."
        )
        XCTAssertEqual(
            viewModel.cycleDay,
            1,
            "cycleDay must default to 1 when no cycles are recorded."
        )
        XCTAssertEqual(
            viewModel.cycleLength,
            Constants.Cycle.defaultLength,
            "cycleLength must use the default when no cycles are recorded."
        )
        XCTAssertNil(
            viewModel.daysLate,
            "daysLate must be nil when no cycles are recorded."
        )
    }

    // MARK: - Refresh with Cycles

    func testRefreshWithCycles_computesPrediction() {
        // Insert enough cycles to produce a prediction, then verify the view-model
        // reflects the computed state after refresh().
        seedCycles(count: 4, lengthDays: 28)
        viewModel.refresh()

        XCTAssertNotNil(
            viewModel.prediction,
            "prediction must not be nil after refresh() when cycle data exists."
        )
        XCTAssertGreaterThan(
            viewModel.cycleLength,
            0,
            "cycleLength must be a positive integer after a successful prediction."
        )
    }

    func testRefreshWithCycles_updatesCycleDay() {
        // The most-recent cycle starts today → cycleDay should be 1.
        let todayStart = Calendar.current.startOfDay(for: Date())
        let cycle = CycleEntry(startDate: todayStart, isConfirmed: true)
        dependencies.cycleRepository.saveCycle(cycle)
        viewModel.refresh()

        XCTAssertEqual(
            viewModel.cycleDay,
            1,
            "When the most-recent period starts today, cycleDay must be 1."
        )
    }

    // MARK: - Water Intake

    func testAddWater_incrementsIntake() {
        viewModel.addWater(ml: 250)
        XCTAssertEqual(
            viewModel.waterIntake,
            250,
            "addWater(ml:250) must set waterIntake to 250."
        )
    }

    func testAddWater_accumulatesMultipleCalls() {
        viewModel.addWater(ml: 250)
        viewModel.addWater(ml: 250)
        viewModel.addWater(ml: 500)
        XCTAssertEqual(
            viewModel.waterIntake,
            1000,
            "Multiple addWater calls must accumulate correctly."
        )
    }

    func testAddWater_persistedToLog() {
        viewModel.addWater(ml: 300)
        XCTAssertNotNil(
            viewModel.todayLog,
            "addWater must create or update todayLog."
        )
        XCTAssertEqual(
            viewModel.todayLog?.waterIntakeMl,
            300,
            "todayLog.waterIntakeMl must reflect the added water."
        )
    }

    // MARK: - Water Progress

    func testWaterProgress_zero() {
        XCTAssertEqual(
            viewModel.waterProgress,
            0.0,
            accuracy: 0.001,
            "waterProgress must be 0.0 when no water has been logged."
        )
    }

    func testWaterProgress_calculatedCorrectly() {
        viewModel.addWater(ml: 1000)
        let expected = Double(1000) / Double(viewModel.waterGoal)
        XCTAssertEqual(
            viewModel.waterProgress,
            expected,
            accuracy: 0.001,
            "waterProgress must equal intake / goal."
        )
    }

    func testWaterProgress_capsAtOne() {
        // Adding more than the daily goal must not push waterProgress above 1.0.
        viewModel.addWater(ml: viewModel.waterGoal + 500)
        XCTAssertEqual(
            viewModel.waterProgress,
            1.0,
            accuracy: 0.001,
            "waterProgress must be capped at 1.0 even when intake exceeds the goal."
        )
    }

    // MARK: - Greeting

    func testGreeting_containsTimeBasedWord() {
        // We cannot control the system clock in unit tests, so we confirm
        // the greeting contains one of the three expected time-based prefixes.
        let validGreetings = ["Good morning", "Good afternoon", "Good evening"]
        let matches = validGreetings.contains(where: { viewModel.greeting.hasPrefix($0) })
        XCTAssertTrue(
            matches,
            "greeting must start with 'Good morning', 'Good afternoon', or 'Good evening'. Got: '\(viewModel.greeting)'"
        )
    }

    func testGreeting_includesUserNameWhenSet() {
        dependencies.settingsManager.userName = "Aria"
        viewModel.refresh()

        XCTAssertTrue(
            viewModel.greeting.contains("Aria"),
            "When a user name is set, greeting must include that name. Got: '\(viewModel.greeting)'"
        )
    }

    func testGreeting_omitsNameWhenEmpty() {
        dependencies.settingsManager.userName = ""
        viewModel.refresh()

        let validGreetings = ["Good morning", "Good afternoon", "Good evening"]
        XCTAssertTrue(
            validGreetings.contains(viewModel.greeting),
            "When user name is empty, greeting must be only the time-based phrase. Got: '\(viewModel.greeting)'"
        )
    }

    func testGreeting_omitsNameWhenWhitespaceOnly() {
        dependencies.settingsManager.userName = "   "
        viewModel.refresh()

        // A whitespace-only name is trimmed to empty, so the greeting should
        // not append a space followed by whitespace.
        let validGreetings = ["Good morning", "Good afternoon", "Good evening"]
        XCTAssertTrue(
            validGreetings.contains(viewModel.greeting),
            "When user name is whitespace only, greeting must be the bare time-based phrase. Got: '\(viewModel.greeting)'"
        )
    }

    // MARK: - Log Period Start

    func testLogPeriodStart_createsCycle() {
        viewModel.logPeriodStart()

        let cycles = dependencies.cycleRepository.fetchAllCycles()
        XCTAssertEqual(
            cycles.count,
            1,
            "logPeriodStart() must create exactly one CycleEntry."
        )
        XCTAssertTrue(
            cycles[0].isConfirmed,
            "The cycle created by logPeriodStart() must be confirmed."
        )
        XCTAssertEqual(
            Calendar.current.startOfDay(for: cycles[0].startDate),
            Calendar.current.startOfDay(for: Date()),
            "logPeriodStart() must create a cycle with today's start date."
        )
    }

    func testLogPeriodStart_triggersRefresh() {
        // After logPeriodStart(), refresh() is called internally.
        // With one cycle the prediction stays nil (single entry), but cycleDay
        // must be updated to 1 (today is day 1 of the new cycle).
        viewModel.logPeriodStart()
        XCTAssertEqual(
            viewModel.cycleDay,
            1,
            "After logPeriodStart, cycleDay should be 1 because the period started today."
        )
    }

    // MARK: - End Period

    func testEndPeriod_setsEndDate() {
        // Start a period first, then end it.
        viewModel.logPeriodStart()

        viewModel.endPeriod()

        let activeCycle = dependencies.cycleRepository.fetchActiveCycle()
        XCTAssertNotNil(
            activeCycle?.endDate,
            "endPeriod() must set an endDate on the active cycle."
        )
        XCTAssertEqual(
            Calendar.current.startOfDay(for: activeCycle!.endDate!),
            Calendar.current.startOfDay(for: Date()),
            "The endDate set by endPeriod() must be today."
        )
    }

    func testEndPeriod_isNoOpWhenNoActiveCycle() {
        // Calling endPeriod() when there is no active cycle must not crash and
        // must not create any spurious entries.
        viewModel.endPeriod()
        XCTAssertEqual(
            dependencies.cycleRepository.fetchAllCycles().count,
            0,
            "endPeriod() on empty store must not create any CycleEntry."
        )
    }

    func testEndPeriod_isNoOpWhenAlreadyEnded() {
        // Start and immediately end a cycle, then call endPeriod() again.
        viewModel.logPeriodStart()
        viewModel.endPeriod()

        if let endDate = dependencies.cycleRepository.fetchActiveCycle()?.endDate {
            viewModel.endPeriod()
            // The end date should not have changed.
            XCTAssertEqual(
                Calendar.current.startOfDay(for: dependencies.cycleRepository.fetchActiveCycle()!.endDate!),
                Calendar.current.startOfDay(for: endDate),
                "Calling endPeriod() twice must not change the already-set endDate."
            )
        }
    }

    // MARK: - isPeriodActive

    func testIsPeriodActive_falseWhenNoCycle() {
        XCTAssertFalse(
            viewModel.isPeriodActive,
            "isPeriodActive must be false when no cycles exist."
        )
    }

    func testIsPeriodActive_trueWhenOpenCycle() {
        viewModel.logPeriodStart()
        XCTAssertTrue(
            viewModel.isPeriodActive,
            "isPeriodActive must be true when there is a confirmed cycle with no endDate."
        )
    }

    func testIsPeriodActive_falseAfterEndPeriod() {
        viewModel.logPeriodStart()
        viewModel.endPeriod()
        XCTAssertFalse(
            viewModel.isPeriodActive,
            "isPeriodActive must be false after the period has been ended."
        )
    }

    // MARK: - Private Helpers

    /// Seeds `count` cycle entries with the given `lengthDays` spacing, ending at today.
    private func seedCycles(count: Int, lengthDays: Int) {
        var current = Calendar.current.date(
            byAdding: .day,
            value: -(count * lengthDays),
            to: Calendar.current.startOfDay(for: Date())
        )!
        for _ in 0..<count {
            let entry = CycleEntry(startDate: current, isConfirmed: true)
            dependencies.cycleRepository.saveCycle(entry)
            current = Calendar.current.date(byAdding: .day, value: lengthDays, to: current)!
        }
    }
}
