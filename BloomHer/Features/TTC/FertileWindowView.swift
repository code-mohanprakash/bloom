//
//  FertileWindowView.swift
//  BloomHer
//
//  Fertility-focused calendar view. Shows the current month with each day
//  shaded by its fertility probability. Ovulation day receives a special
//  marker. A legend and phase-tips card accompany the calendar.
//

import SwiftUI

// MARK: - FertileWindowView

struct FertileWindowView: View {

    // MARK: Dependencies

    let viewModel: TTCViewModel

    // MARK: State

    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())
    @Environment(\.dismiss) private var dismiss

    // MARK: Calendar helpers

    private var calendar: Calendar { Calendar.current }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        return range.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: displayedMonth)
        }
    }

    private var firstWeekdayOffset: Int {
        let weekday = calendar.component(.weekday, from: displayedMonth)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    monthNavigationHeader
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    calendarGrid
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    fertilityLegend
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    phaseInfoCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    estimateDisclaimer
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Fertile Window")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
        }
    }

    // MARK: - Month Navigation

    private var monthNavigationHeader: some View {
        HStack {
            Button {
                BloomHerTheme.Haptics.selection()
                withAnimation(BloomHerTheme.Animation.standard) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(BloomIcons.chevronLeft)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .contentTransition(.numericText())
                .animation(BloomHerTheme.Animation.standard, value: displayedMonth)

            Spacer()

            Button {
                BloomHerTheme.Haptics.selection()
                withAnimation(BloomHerTheme.Animation.standard) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(BloomIcons.chevronRight)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, BloomHerTheme.Spacing.xxs)

            // Day cells
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                // Offset blank cells
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }

                ForEach(daysInMonth, id: \.self) { date in
                    FertilityDayCell(
                        date: date,
                        fertility: fertilityLevel(for: date),
                        isToday: calendar.isDateInToday(date),
                        isOvulation: isOvulationDay(date)
                    )
                }
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xl, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // MARK: - Legend

    private var fertilityLegend: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Fertility Probability")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                HStack(spacing: BloomHerTheme.Spacing.lg) {
                    legendItem(color: BloomHerTheme.Colors.sageGreen.opacity(0.3),  label: "Low")
                    legendItem(color: BloomHerTheme.Colors.sageGreen,               label: "Medium")
                    legendItem(color: BloomHerTheme.Colors.accentPeach,             label: "High")
                    legendItem(color: BloomHerTheme.Colors.primaryRose,             label: "Peak")
                }

                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(BloomHerTheme.Colors.primaryRose)
                            .frame(width: 20, height: 20)
                        Image(BloomIcons.starFilled)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 9, height: 9)
                            .foregroundStyle(.white)
                    }
                    Text("Estimated ovulation day")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                .fill(color)
                .frame(width: 28, height: 28)
            Text(label)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
    }

    // MARK: - Phase Tips Card

    @ViewBuilder
    private var phaseInfoCard: some View {
        let phase = viewModel.currentPhase
        BloomCard(isPhaseAware: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(phase.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("\(phase.displayName) Phase Tip")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }
                Text(phaseFertilityTip(for: phase))
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .environment(\.currentCyclePhase, phase)
    }

    // MARK: - Disclaimer

    private var estimateDisclaimer: some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
            Image(BloomIcons.warning)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(BloomHerTheme.Colors.warning)
            Text("This is an estimate based on your cycle history. Fertile window predictions become more accurate with more cycles logged. Use alongside OPK tests and BBT tracking for best results.")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.warning.opacity(0.08))
        )
    }

    // MARK: - Helpers

    private var shortWeekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }

    /// Assigns a fertility level (0–3) to each calendar day.
    private func fertilityLevel(for date: Date) -> Int {
        guard let start = viewModel.fertileWindowStart,
              let end   = viewModel.fertileWindowEnd else { return 0 }

        let day           = calendar.startOfDay(for: date)
        let windowStart   = calendar.startOfDay(for: start)
        let windowEnd     = calendar.startOfDay(for: end)
        let ovulationDay  = calendar.startOfDay(for: viewModel.estimatedOvulationDate ?? end)

        if day == ovulationDay                  { return 3 }   // peak
        if day >= calendar.date(byAdding: .day, value: -2, to: ovulationDay)! &&
           day <= windowEnd                     { return 2 }   // high
        if day >= windowStart && day < calendar.date(byAdding: .day, value: -2, to: ovulationDay)! { return 1 } // medium
        return 0                                               // low / none
    }

    private func isOvulationDay(_ date: Date) -> Bool {
        guard let ov = viewModel.estimatedOvulationDate else { return false }
        return calendar.isDate(date, inSameDayAs: ov)
    }

    private func phaseFertilityTip(for phase: CyclePhase) -> String {
        switch phase {
        case .menstrual:
            return "Your period is active. Fertility is at its lowest right now — rest and recover. The fertile window is still weeks away."
        case .follicular:
            return "Follicles are developing and oestrogen is rising. Your fertile window is approaching — a great time to start daily OPK testing."
        case .ovulation:
            return "You are in or near your fertile window. LH surges typically occur 24–36 hours before ovulation. This is the best time for conception."
        case .luteal:
            return "Ovulation has likely passed. If you are in the two-week wait, try to stay busy and avoid testing too early. Results before day 10 post-ovulation are unreliable."
        }
    }
}

// MARK: - FertilityDayCell

private struct FertilityDayCell: View {
    let date: Date
    let fertility: Int    // 0 = none, 1 = medium, 2 = high, 3 = peak
    let isToday: Bool
    let isOvulation: Bool

    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    private var cellColor: Color {
        switch fertility {
        case 1: return BloomHerTheme.Colors.sageGreen.opacity(0.35)
        case 2: return BloomHerTheme.Colors.accentPeach.opacity(0.70)
        case 3: return BloomHerTheme.Colors.primaryRose.opacity(0.85)
        default: return Color.clear
        }
    }

    var body: some View {
        ZStack {
            // Background fill
            if fertility > 0 {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .fill(cellColor)
            }

            // Today ring
            if isToday {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .strokeBorder(BloomHerTheme.Colors.primaryRose, lineWidth: 2)
            }

            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(BloomHerTheme.Typography.footnote)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(fertility == 3 ? .white : BloomHerTheme.Colors.textPrimary)

                // Ovulation star marker
                if isOvulation {
                    Image(BloomIcons.starFilled)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 7)
                }
            }
        }
        .frame(height: 44)
        .animation(BloomHerTheme.Animation.quick, value: fertility)
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - Preview

#Preview("Fertile Window") {
    FertileWindowView(viewModel: {
        let vm = TTCViewModel(dependencies: AppDependencies.preview())
        vm.refresh()
        return vm
    }())
    .environment(\.currentCyclePhase, .ovulation)
}
