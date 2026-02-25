//
//  CycleCalendarView.swift
//  BloomHer
//
//  Full calendar tab screen. Shows a month navigation header, a Mon–Sun
//  weekday label row, a 6×7 grid of day cells, a cycle stats bar, and
//  a "Log Today" floating action button. Tapping a day opens DayDetailSheet.
//

import SwiftUI

// MARK: - CycleCalendarView

/// The primary calendar screen for the Calendar tab.
///
/// Composes `CalendarMonthHeader`, the weekday-labels row, a lazy grid of
/// day cells, `CycleLengthStatsBar`, and a floating "Log Today" FAB.
/// Selecting a date or tapping the FAB presents `DayDetailSheet` as a sheet.
struct CycleCalendarView: View {

    // MARK: State

    @State private var viewModel: CalendarViewModel

    // MARK: Environment

    @Environment(AppDependencies.self) private var dependencies

    // MARK: Init

    init(viewModel: CalendarViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    // Month navigation header
                    CalendarMonthHeader(
                        currentMonth: viewModel.currentMonth,
                        onPrevious: viewModel.previousMonth,
                        onNext: viewModel.nextMonth
                    )
                    .padding(.top, BloomHerTheme.Spacing.sm)

                    // Decorative hero header
                    calendarHeroDecoration

                    // Weekday labels
                    weekdayLabelsRow
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .padding(.vertical, BloomHerTheme.Spacing.xs)

                    // Calendar day grid
                    calendarGrid
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .animation(BloomHerTheme.Animation.standard, value: viewModel.currentMonth)

                    // Phase legend
                    calendarLegend
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .padding(.top, BloomHerTheme.Spacing.md)

                    // Stats bar
                    CycleLengthStatsBar(prediction: viewModel.prediction)
                        .padding(.top, BloomHerTheme.Spacing.sm)

                    // Bottom padding for FAB clearance
                    Spacer(minLength: BloomHerTheme.Spacing.massive)
                }
            }
            .bloomBackground()

            // Floating "Log Today" button
            logTodayFAB
                .padding(.trailing, BloomHerTheme.Spacing.md)
                .padding(.bottom, BloomHerTheme.Spacing.xl)
        }
        .sheet(isPresented: $viewModel.showDayDetail) {
            viewModel.refreshData()
        } content: {
            if let date = viewModel.selectedDate {
                DayDetailSheet(
                    viewModel: DayDetailViewModel(
                        date: date,
                        cycleRepository: dependencies.cycleRepository
                    )
                )
                .bloomSheet(detents: [.large])
            }
        }
    }

    // MARK: Calendar Hero Decoration

    private var calendarHeroDecoration: some View {
        Image(BloomIcons.heroCalendar)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .overlay(
                LinearGradient(
                    colors: [.clear, BloomHerTheme.Colors.background.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            )
            .opacity(0.85)
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.top, BloomHerTheme.Spacing.xs)
            .staggeredAppear(index: 0)
    }

    // MARK: Weekday Labels

    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]

    private var weekdayLabelsRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(BloomHerTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        // Dim Saturday/Sunday
                        index >= 5
                        ? BloomHerTheme.Colors.textTertiary
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Calendar Grid

    private let columns = Array(repeating: GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xxs), count: 7)

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: BloomHerTheme.Spacing.xxs) {
            ForEach(Array(viewModel.calendarGridDates.enumerated()), id: \.offset) { _, optDate in
                if let date = optDate {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let isSelected = viewModel.selectedDate.map { date.isSameDay(as: $0) } ?? false
        let phase = viewModel.phaseFor(date: date)
        let flowLevel = viewModel.flowLevelFor(date: date)
        let isFertile = viewModel.isFertile(date: date)
        let isPredicted = viewModel.isPredictedPeriod(date: date)
        let isOvulation = viewModel.isOvulationDay(date: date)
        let isPeriodStart = viewModel.isPeriodStart(date: date)

        Button {
            BloomHerTheme.Haptics.selection()
            viewModel.selectDate(date)
        } label: {
            CalendarDayCell(
                date: date,
                phase: phase,
                flowLevel: flowLevel,
                isSelected: isSelected,
                isFertile: isFertile,
                isPredictedPeriod: isPredicted,
                isOvulationDay: isOvulation,
                isPeriodStart: isPeriodStart
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: Calendar Legend

    private var calendarLegend: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Legend")
                    .font(BloomHerTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                let items: [(Color, String)] = [
                    (BloomColors.menstrual,   "Menstrual"),
                    (BloomColors.follicular,  "Follicular"),
                    (BloomColors.ovulation,   "Ovulation"),
                    (BloomColors.luteal,      "Luteal"),
                ]

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(items, id: \.1) { color, label in
                        HStack(spacing: BloomHerTheme.Spacing.xxs) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(color.opacity(0.40))
                                .frame(width: 12, height: 12)
                            Text(label)
                                .font(BloomHerTheme.Typography.caption2)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }
                    }

                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Circle()
                            .fill(BloomColors.menstrual)
                            .frame(width: 6, height: 6)
                            .padding(.leading, 3)
                        Text("Period day")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }

                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Circle()
                            .fill(BloomColors.menstrual.opacity(0.45))
                            .frame(width: 5, height: 5)
                            .padding(.leading, 3.5)
                        Text("Predicted")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: Log Today FAB

    private var logTodayFAB: some View {
        Button {
            BloomHerTheme.Haptics.medium()
            viewModel.selectDate(Date())
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
                Image(BloomIcons.plus)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: BloomHerTheme.IconSize.inline, height: BloomHerTheme.IconSize.inline)
                Text("Log Today")
                    .font(BloomHerTheme.Typography.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(BloomColors.primaryRose)
            .clipShape(Capsule())
            .shadow(
                color: BloomHerTheme.Colors.primaryRose.opacity(0.40),
                radius: 12, x: 0, y: 4
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - CalendarDayCell

/// An individual day cell for the calendar grid.
///
/// This is a private implementation detail of `CycleCalendarView`. It renders
/// the day number, phase background, flow dot, fertility ring, and prediction
/// overlay so the grid stays decoupled from `BloomCalendarDay`.
private struct CalendarDayCell: View {

    let date: Date
    let phase: CyclePhase?
    let flowLevel: FlowLevel?
    let isSelected: Bool
    let isFertile: Bool
    let isPredictedPeriod: Bool
    let isOvulationDay: Bool
    let isPeriodStart: Bool

    private var isToday: Bool { date.isToday }

    var body: some View {
        ZStack {
            // Background fill
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                .fill(backgroundFill)

            // Selection / today ring
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                .strokeBorder(ringColor, lineWidth: ringWidth)

            VStack(spacing: 2) {
                // Day number
                Text("\(date.day)")
                    .font(BloomHerTheme.Typography.caption)
                    .fontWeight(isToday || isSelected ? .bold : .regular)
                    .foregroundStyle(dayNumberColor)

                // Flow / indicator dot
                indicator
            }
            .padding(.vertical, 4)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: Appearance

    private var backgroundFill: Color {
        if isSelected {
            return BloomHerTheme.Colors.primaryRose.opacity(0.20)
        }
        if let phase {
            return BloomColors.color(for: phase).opacity(isPredictedPeriod ? 0.08 : 0.12)
        }
        if isPredictedPeriod {
            return BloomColors.menstrual.opacity(0.06)
        }
        return Color.clear
    }

    private var ringColor: Color {
        if isSelected { return BloomHerTheme.Colors.primaryRose }
        if isToday { return BloomHerTheme.Colors.primaryRose.opacity(0.50) }
        if isFertile { return BloomColors.sageGreen.opacity(0.60) }
        return Color.clear
    }

    private var ringWidth: CGFloat {
        isSelected ? 2 : 1.5
    }

    private var dayNumberColor: Color {
        if isSelected { return BloomHerTheme.Colors.primaryRose }
        if isToday { return BloomHerTheme.Colors.primaryRose }
        if let phase { return BloomColors.color(for: phase) }
        return BloomHerTheme.Colors.textSecondary
    }

    @ViewBuilder
    private var indicator: some View {
        if let flowLevel, flowLevel != .spotting {
            Circle()
                .fill(BloomColors.menstrual)
                .frame(width: 5, height: 5)
        } else if isOvulationDay {
            Circle()
                .fill(BloomColors.accentPeach)
                .frame(width: 5, height: 5)
        } else if isPredictedPeriod {
            Circle()
                .fill(BloomColors.menstrual.opacity(0.45))
                .frame(width: 4, height: 4)
        } else if flowLevel == .spotting {
            Circle()
                .fill(BloomColors.menstrual.opacity(0.60))
                .frame(width: 4, height: 4)
        } else {
            Color.clear
                .frame(width: 5, height: 5)
        }
    }
}

// MARK: - Preview

#Preview("Cycle Calendar View") {
    let deps = AppDependencies.preview()
    let vm = CalendarViewModel(
        cycleRepository: deps.cycleRepository,
        predictionService: deps.cyclePredictionService
    )
    return CycleCalendarView(viewModel: vm)
        .environment(deps)
        .environment(\.currentCyclePhase, .follicular)
}
