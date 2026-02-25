//
//  CycleRepositoryTests.swift
//  BloomHerTests
//
//  Integration tests for CycleRepository using an in-memory SwiftData
//  container so no persistent state bleeds between test runs.
//

import XCTest
import SwiftData
@testable import BloomHer

@MainActor
final class CycleRepositoryTests: XCTestCase {

    // MARK: - Dependencies

    private var container: ModelContainer!
    private var context: ModelContext!
    private var repository: CycleRepository!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        container  = DataConfiguration.makeInMemoryContainer()
        context    = container.mainContext
        repository = CycleRepository(context: context)
    }

    override func tearDown() {
        repository = nil
        context    = nil
        container  = nil
        super.tearDown()
    }

    // MARK: - CycleEntry: Save & Fetch All

    func testSaveCycleAndFetchAll() {
        let cycle = CycleEntry(startDate: date(2025, 3, 1), isConfirmed: true)
        repository.saveCycle(cycle)

        let all = repository.fetchAllCycles()
        XCTAssertEqual(all.count, 1, "fetchAllCycles should return the one saved entry.")
        XCTAssertEqual(
            Calendar.current.startOfDay(for: all[0].startDate),
            Calendar.current.startOfDay(for: date(2025, 3, 1)),
            "The fetched cycle start date must match the saved value."
        )
    }

    func testFetchAllCycles_sortedAscending() {
        // Insert out-of-order and verify the return is ascending by startDate.
        repository.saveCycle(CycleEntry(startDate: date(2025, 3, 1)))
        repository.saveCycle(CycleEntry(startDate: date(2025, 1, 1)))
        repository.saveCycle(CycleEntry(startDate: date(2025, 2, 1)))

        let all = repository.fetchAllCycles()
        XCTAssertEqual(all.count, 3, "fetchAllCycles should return all 3 entries.")
        XCTAssertTrue(
            all[0].startDate < all[1].startDate && all[1].startDate < all[2].startDate,
            "fetchAllCycles must return cycles in ascending startDate order."
        )
    }

    // MARK: - CycleEntry: Fetch Recent (limit)

    func testFetchRecentCycles_respectsLimit() {
        for i in 1...5 {
            repository.saveCycle(CycleEntry(startDate: date(2025, i, 1)))
        }

        let recent = repository.fetchRecentCycles(count: 3)
        XCTAssertEqual(recent.count, 3, "fetchRecentCycles(count:3) must return exactly 3 entries.")
    }

    func testFetchRecentCycles_returnsNewest() {
        // Insert 4 cycles; fetching 2 should give the most-recent 2.
        repository.saveCycle(CycleEntry(startDate: date(2025, 1, 1)))
        repository.saveCycle(CycleEntry(startDate: date(2025, 2, 1)))
        repository.saveCycle(CycleEntry(startDate: date(2025, 3, 1)))
        repository.saveCycle(CycleEntry(startDate: date(2025, 4, 1)))

        let recent = repository.fetchRecentCycles(count: 2)
        let starts = recent.map { Calendar.current.startOfDay(for: $0.startDate) }.sorted(by: >)

        XCTAssertEqual(starts[0], Calendar.current.startOfDay(for: date(2025, 4, 1)), "Newest entry should be April 1.")
        XCTAssertEqual(starts[1], Calendar.current.startOfDay(for: date(2025, 3, 1)), "Second-newest should be March 1.")
    }

    // MARK: - CycleEntry: Fetch for Date

    func testFetchCycleForDate() {
        let target = date(2025, 5, 15)
        repository.saveCycle(CycleEntry(startDate: target))
        repository.saveCycle(CycleEntry(startDate: date(2025, 5, 20)))

        let fetched = repository.fetchCycle(for: target)
        XCTAssertNotNil(fetched, "fetchCycle(for:) must return a cycle that starts on the given date.")
        XCTAssertEqual(
            Calendar.current.startOfDay(for: fetched!.startDate),
            Calendar.current.startOfDay(for: target),
            "The returned cycle must start on the queried date."
        )
    }

    func testFetchCycleForDate_returnsNilWhenAbsent() {
        repository.saveCycle(CycleEntry(startDate: date(2025, 5, 20)))

        let fetched = repository.fetchCycle(for: date(2025, 5, 15))
        XCTAssertNil(fetched, "fetchCycle(for:) must return nil when no cycle starts on that date.")
    }

    // MARK: - CycleEntry: Fetch Active Cycle

    func testFetchActiveCycle_returnsConfirmed() {
        // Only confirmed cycles should be returned as the active cycle.
        let unconfirmed = CycleEntry(startDate: date(2025, 5, 1), isConfirmed: false)
        let confirmed   = CycleEntry(startDate: date(2025, 5, 15), isConfirmed: true)
        repository.saveCycle(unconfirmed)
        repository.saveCycle(confirmed)

        let active = repository.fetchActiveCycle()
        XCTAssertNotNil(active, "fetchActiveCycle must not return nil when a confirmed entry exists.")
        XCTAssertTrue(active!.isConfirmed, "fetchActiveCycle must only return confirmed entries.")
    }

    func testFetchActiveCycle_returnsNilWhenOnlyUnconfirmed() {
        let unconfirmed = CycleEntry(startDate: date(2025, 5, 1), isConfirmed: false)
        repository.saveCycle(unconfirmed)

        let active = repository.fetchActiveCycle()
        XCTAssertNil(active, "fetchActiveCycle must return nil when only unconfirmed entries exist.")
    }

    func testFetchActiveCycle_returnsMostRecent() {
        repository.saveCycle(CycleEntry(startDate: date(2025, 3, 1), isConfirmed: true))
        repository.saveCycle(CycleEntry(startDate: date(2025, 4, 1), isConfirmed: true))
        repository.saveCycle(CycleEntry(startDate: date(2025, 5, 1), isConfirmed: true))

        let active = repository.fetchActiveCycle()
        XCTAssertNotNil(active)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: active!.startDate),
            Calendar.current.startOfDay(for: date(2025, 5, 1)),
            "fetchActiveCycle must return the most-recent confirmed entry."
        )
    }

    // MARK: - CycleEntry: Delete

    func testDeleteCycle_removesFromStore() {
        let cycle = CycleEntry(startDate: date(2025, 6, 1))
        repository.saveCycle(cycle)
        XCTAssertEqual(repository.fetchAllCycles().count, 1, "Prerequisite: cycle must be persisted before deletion.")

        repository.deleteCycle(cycle)
        XCTAssertEqual(
            repository.fetchAllCycles().count,
            0,
            "deleteCycle must remove the entry from the persistent store."
        )
    }

    func testDeleteCycle_doesNotAffectOtherEntries() {
        let keepCycle   = CycleEntry(startDate: date(2025, 6, 1))
        let deleteCycle = CycleEntry(startDate: date(2025, 7, 1))
        repository.saveCycle(keepCycle)
        repository.saveCycle(deleteCycle)

        repository.deleteCycle(deleteCycle)
        let remaining = repository.fetchAllCycles()
        XCTAssertEqual(remaining.count, 1, "Deleting one cycle must not affect other cycles.")
        XCTAssertEqual(
            Calendar.current.startOfDay(for: remaining[0].startDate),
            Calendar.current.startOfDay(for: date(2025, 6, 1)),
            "The remaining cycle should be the one that was not deleted."
        )
    }

    // MARK: - DailyLog: Save & Fetch by Date

    func testSaveDailyLog_andFetchByDate() {
        let logDate = date(2025, 8, 10)
        let log = DailyLog(date: logDate)
        log.waterIntakeMl = 1500
        repository.saveDailyLog(log)

        let fetched = repository.fetchDailyLog(for: logDate)
        XCTAssertNotNil(fetched, "fetchDailyLog(for:) must find a log saved for the same day.")
        XCTAssertEqual(
            fetched?.waterIntakeMl,
            1500,
            "The fetched log must carry the same water intake that was saved."
        )
    }

    func testFetchDailyLog_returnsNilForDifferentDay() {
        let log = DailyLog(date: date(2025, 8, 10))
        repository.saveDailyLog(log)

        let fetched = repository.fetchDailyLog(for: date(2025, 8, 11))
        XCTAssertNil(
            fetched,
            "fetchDailyLog(for:) must return nil when no log exists for the queried day."
        )
    }

    // MARK: - DailyLog: fetchOrCreate

    func testFetchOrCreateDailyLog_createsNew() {
        let targetDate = date(2025, 9, 5)
        XCTAssertNil(
            repository.fetchDailyLog(for: targetDate),
            "Prerequisite: no log should exist for the target date yet."
        )

        let log = repository.fetchOrCreateDailyLog(for: targetDate)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: log.date),
            Calendar.current.startOfDay(for: targetDate),
            "fetchOrCreateDailyLog must create a new log with the correct date."
        )
        XCTAssertNotNil(
            repository.fetchDailyLog(for: targetDate),
            "After fetchOrCreate, the new log must be persisted and retrievable."
        )
    }

    func testFetchOrCreateDailyLog_returnsExisting() {
        let targetDate = date(2025, 9, 5)
        let existing   = DailyLog(date: targetDate)
        existing.waterIntakeMl = 800
        repository.saveDailyLog(existing)

        let fetched = repository.fetchOrCreateDailyLog(for: targetDate)
        XCTAssertEqual(
            fetched.waterIntakeMl,
            800,
            "fetchOrCreateDailyLog must return the existing log rather than creating a new one."
        )

        // Confirm there is still only one log for this date.
        let allLogs = repository.fetchDailyLogs(from: targetDate, to: targetDate)
        XCTAssertEqual(
            allLogs.count,
            1,
            "fetchOrCreate must not create a duplicate when a log already exists."
        )
    }

    // MARK: - DailyLog: Date Range Fetch

    func testFetchDailyLogs_dateRange() {
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 1)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 5)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 10)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 15)))

        let logs = repository.fetchDailyLogs(from: date(2025, 10, 4), to: date(2025, 10, 11))
        XCTAssertEqual(
            logs.count,
            2,
            "fetchDailyLogs(from:to:) must return only logs whose dates fall within the closed range."
        )
    }

    func testFetchDailyLogs_inclusiveBoundaries() {
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 1)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 7)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 14)))

        // Fetch exactly [Oct 1, Oct 7] — both boundary dates must be included.
        let logs = repository.fetchDailyLogs(from: date(2025, 10, 1), to: date(2025, 10, 7))
        XCTAssertEqual(
            logs.count,
            2,
            "fetchDailyLogs must include logs on the start and end boundary dates."
        )
    }

    func testFetchDailyLogs_emptyWhenNoMatches() {
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 20)))

        let logs = repository.fetchDailyLogs(from: date(2025, 10, 1), to: date(2025, 10, 10))
        XCTAssertTrue(
            logs.isEmpty,
            "fetchDailyLogs must return an empty array when no logs exist in the range."
        )
    }

    func testFetchDailyLogs_sortedAscending() {
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 5)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 3)))
        repository.saveDailyLog(DailyLog(date: date(2025, 10, 7)))

        let logs = repository.fetchDailyLogs(from: date(2025, 10, 1), to: date(2025, 10, 31))
        XCTAssertEqual(logs.count, 3, "Prerequisite: three logs in range.")
        XCTAssertTrue(
            logs[0].date < logs[1].date && logs[1].date < logs[2].date,
            "fetchDailyLogs must return results in ascending date order."
        )
    }

    // MARK: - Private Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year  = year
        components.month = month
        components.day   = day
        return Calendar.current.date(from: components)!
    }
}
