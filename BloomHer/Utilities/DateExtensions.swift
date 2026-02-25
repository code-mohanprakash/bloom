//
//  DateExtensions.swift
//  BloomHer
//
//  Expressive Date helpers used throughout cycle calculation, calendar
//  rendering, and log display.  All properties and methods are pure — they
//  never mutate state and carry no side effects.
//

import Foundation

// MARK: - Calendar constant

private extension Calendar {
    /// Shared `gregorian` calendar pre-configured with the device's locale
    /// and time zone so that "day" boundaries match the user's clock.
    static let bloomHer: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale   = .current
        cal.timeZone = .current
        return cal
    }()
}

// MARK: - Date + BloomHer

public extension Date {

    // MARK: Day Boundaries

    /// The first instant of the calendar day containing this date (00:00:00).
    var startOfDay: Date {
        Calendar.bloomHer.startOfDay(for: self)
    }

    /// The last instant of the calendar day containing this date (23:59:59).
    var endOfDay: Date {
        var components        = DateComponents()
        components.day        = 1
        components.second     = -1
        return Calendar.bloomHer.date(byAdding: components, to: startOfDay) ?? self
    }

    // MARK: Relative Day Arithmetic

    /// The number of whole calendar days from `self` until `date`.
    ///
    /// Returns a positive integer when `date` is in the future.
    /// Returns 0 when `date` is the same calendar day.
    /// Returns a negative integer when `date` is in the past.
    ///
    /// - Parameter date: The target date.
    /// - Returns: Signed day count.
    func daysUntil(_ date: Date) -> Int {
        Calendar.bloomHer.dateComponents(
            [.day],
            from: startOfDay,
            to:   date.startOfDay
        ).day ?? 0
    }

    /// The number of whole calendar days that have passed since `date`.
    ///
    /// Equivalent to `date.daysUntil(self)`.  Returns a positive integer
    /// when `date` is in the past.
    ///
    /// - Parameter date: The reference date.
    /// - Returns: Signed day count.
    func daysSince(_ date: Date) -> Int {
        Calendar.bloomHer.dateComponents(
            [.day],
            from: date.startOfDay,
            to:   startOfDay
        ).day ?? 0
    }

    /// Returns a new `Date` by adding the given number of calendar days.
    ///
    /// Passing a negative value moves backwards in time.
    ///
    /// - Parameter days: Number of days to add (may be negative).
    /// - Returns: The adjusted date, or `self` if the calendar operation fails.
    func addingDays(_ days: Int) -> Date {
        Calendar.bloomHer.date(byAdding: .day, value: days, to: self) ?? self
    }

    // MARK: Comparison Helpers

    /// Returns `true` when `other` falls on the same calendar day as `self`.
    ///
    /// - Parameter other: The date to compare against.
    func isSameDay(as other: Date) -> Bool {
        Calendar.bloomHer.isDate(self, inSameDayAs: other)
    }

    /// `true` when `self` falls on today's calendar date.
    var isToday: Bool {
        Calendar.bloomHer.isDateInToday(self)
    }

    // MARK: Formatted Strings

    /// Returns the date formatted with explicit `DateFormatter` style
    /// parameters, respecting the device locale.
    ///
    /// - Parameters:
    ///   - dateStyle: How to represent the date component.
    ///   - timeStyle: How to represent the time component.
    /// - Returns: A locale-aware formatted string.
    func formatted(
        dateStyle: DateFormatter.Style,
        timeStyle: DateFormatter.Style = .none
    ) -> String {
        let formatter        = DateFormatter()
        formatter.dateStyle  = dateStyle
        formatter.timeStyle  = timeStyle
        formatter.locale     = .current
        return formatter.string(from: self)
    }

    /// Returns the full weekday name for this date in the device locale.
    ///
    /// Example (en-US): `"Wednesday"`
    var weekdayName: String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale     = .current
        return formatter.string(from: self)
    }

    /// Returns the abbreviated weekday name for this date in the device locale.
    ///
    /// Example (en-US): `"Wed"`
    var weekdayNameShort: String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale     = .current
        return formatter.string(from: self)
    }

    /// Returns the full month name for this date in the device locale.
    ///
    /// Example (en-US): `"October"`
    var monthName: String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale     = .current
        return formatter.string(from: self)
    }

    /// Returns the abbreviated month name for this date in the device locale.
    ///
    /// Example (en-US): `"Oct"`
    var monthNameShort: String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale     = .current
        return formatter.string(from: self)
    }

    // MARK: Component Accessors

    /// The day-of-month component (1 – 31).
    var day: Int {
        Calendar.bloomHer.component(.day, from: self)
    }

    /// The month component (1 – 12).
    var month: Int {
        Calendar.bloomHer.component(.month, from: self)
    }

    /// The four-digit year component.
    var year: Int {
        Calendar.bloomHer.component(.year, from: self)
    }

    /// The weekday component (1 = Sunday … 7 = Saturday in Gregorian).
    var weekday: Int {
        Calendar.bloomHer.component(.weekday, from: self)
    }
}
