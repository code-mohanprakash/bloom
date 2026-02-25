//
//  BloomDatePicker.swift
//  BloomHer
//
//  A themed wrapper around SwiftUI's `DatePicker` that applies BloomHer
//  typography to the label and tints the picker chrome with `primaryRose`.
//

import SwiftUI

// MARK: - BloomDatePicker

/// A themed `DatePicker` that applies BloomHer label styling and rose tinting.
///
/// `BloomDatePicker` wraps the native `DatePicker` so all accessibility
/// support, localisation, and calendar integration remain intact. It adds:
/// - `BloomHerTheme.Typography.subheadline` for the label.
/// - `.tint(primaryRose)` for the picker chrome and selection.
/// - A consistent surface-colored row background.
///
/// ```swift
/// @State private var lastPeriodDate = Date()
///
/// BloomDatePicker(
///     label: "Last Period Start",
///     date: $lastPeriodDate,
///     displayedComponents: .date
/// )
/// ```
public struct BloomDatePicker: View {

    // MARK: Configuration

    private let label: String
    @Binding private var date: Date
    private let displayedComponents: DatePickerComponents
    private let range: ClosedRange<Date>?

    // MARK: Init

    /// Creates a `BloomDatePicker`.
    ///
    /// - Parameters:
    ///   - label: Descriptive text displayed as the picker's leading label.
    ///   - date: Binding to the selected `Date`.
    ///   - displayedComponents: Which date/time components the picker exposes.
    ///     Defaults to `.date`.
    ///   - range: An optional date range restricting valid selections.
    public init(
        label: String,
        date: Binding<Date>,
        displayedComponents: DatePickerComponents = .date,
        range: ClosedRange<Date>? = nil
    ) {
        self.label = label
        self._date = date
        self.displayedComponents = displayedComponents
        self.range = range
    }

    // MARK: Body

    public var body: some View {
        HStack {
            Text(label)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Spacer()

            picker
                .tint(BloomHerTheme.Colors.primaryRose)
                .labelsHidden()
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .padding(.vertical, BloomHerTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        )
    }

    // MARK: Picker

    @ViewBuilder
    private var picker: some View {
        if let range {
            DatePicker("", selection: $date, in: range, displayedComponents: displayedComponents)
        } else {
            DatePicker("", selection: $date, displayedComponents: displayedComponents)
        }
    }
}

// MARK: - Preview

#Preview("Bloom Date Picker") {
    DatePickerPreviewContainer()
}

private struct DatePickerPreviewContainer: View {
    @State private var startDate = Date()
    @State private var appointmentDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var reminderTime = Date()

    private var dateRange: ClosedRange<Date> {
        let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return start...Date()
    }

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            Text("Cycle Information").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary).frame(maxWidth: .infinity, alignment: .leading)

            BloomDatePicker(label: "Last Period Start", date: $startDate, range: dateRange)

            BloomDatePicker(label: "Next Appointment", date: $appointmentDate, displayedComponents: [.date, .hourAndMinute])

            BloomDatePicker(label: "Daily Reminder", date: $reminderTime, displayedComponents: .hourAndMinute)
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
    }
}
