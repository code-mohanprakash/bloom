//
//  CalendarMonthHeader.swift
//  BloomHer
//
//  Month/year display with leading and trailing navigation chevrons.
//  Spring animation slides the month label on each navigation action.
//  Haptic feedback fires on every month change.
//

import SwiftUI

// MARK: - CalendarMonthHeader

/// A navigation header that displays the current month and year, with
/// chevron buttons to move to the adjacent months.
///
/// The month label animates with a slide transition when the displayed
/// month changes. A haptic is fired by the parent `CalendarViewModel`;
/// this view is purely presentational and drives navigation via closures.
///
/// ```swift
/// CalendarMonthHeader(
///     currentMonth: viewModel.currentMonth,
///     onPrevious: viewModel.previousMonth,
///     onNext: viewModel.nextMonth
/// )
/// ```
public struct CalendarMonthHeader: View {

    // MARK: Input

    /// The month currently displayed in the calendar.
    let currentMonth: Date

    /// Called when the user taps the left (previous month) chevron.
    let onPrevious: () -> Void

    /// Called when the user taps the right (next month) chevron.
    let onNext: () -> Void

    // MARK: State

    @State private var slideDirection: Int = 0  // +1 forward, -1 backward

    // MARK: Body

    public var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            // Previous month button
            navigationButton(
                icon: BloomIcons.chevronLeft,
                accessibilityLabel: "Previous month",
                action: {
                    slideDirection = -1
                    onPrevious()
                }
            )

            Spacer()

            // Month & year display
            VStack(spacing: 2) {
                Text(monthName)
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(yearString)
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .id(currentMonth)
            .transition(monthTransition)
            .animation(BloomHerTheme.Animation.standard, value: currentMonth)
            .accessibilityLabel("\(monthName) \(yearString)")

            Spacer()

            // Next month button
            navigationButton(
                icon: BloomIcons.chevronRight,
                accessibilityLabel: "Next month",
                action: {
                    slideDirection = 1
                    onNext()
                }
            )
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .padding(.vertical, BloomHerTheme.Spacing.xs)
    }

    // MARK: Navigation Button

    @ViewBuilder
    private func navigationButton(
        icon: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 17, height: 17)
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(BloomHerTheme.Colors.primaryRose.opacity(0.10))
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: Helpers

    private var monthName: String {
        currentMonth.formatted(.dateTime.month(.wide))
    }

    private var yearString: String {
        currentMonth.formatted(.dateTime.year())
    }

    private var monthTransition: AnyTransition {
        // Slide in/out based on navigation direction
        let insertion: AnyTransition = slideDirection >= 0
            ? .move(edge: .trailing).combined(with: .opacity)
            : .move(edge: .leading).combined(with: .opacity)
        let removal: AnyTransition = slideDirection >= 0
            ? .move(edge: .leading).combined(with: .opacity)
            : .move(edge: .trailing).combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

// MARK: - Preview

#Preview("Calendar Month Header") {
    CalendarMonthHeaderPreview()
}

private struct CalendarMonthHeaderPreview: View {
    @State private var currentMonth = Date()

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            BloomCard {
                CalendarMonthHeader(
                    currentMonth: currentMonth,
                    onPrevious: {
                        withAnimation(BloomHerTheme.Animation.standard) {
                            currentMonth = Calendar.current.date(
                                byAdding: .month, value: -1, to: currentMonth
                            ) ?? currentMonth
                        }
                    },
                    onNext: {
                        withAnimation(BloomHerTheme.Animation.standard) {
                            currentMonth = Calendar.current.date(
                                byAdding: .month, value: 1, to: currentMonth
                            ) ?? currentMonth
                        }
                    }
                )
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .ovulation)
    }
}
