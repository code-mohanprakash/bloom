//
//  CalendarContainerView.swift
//  BloomHer
//
//  Mode-aware wrapper that routes the Calendar tab to the correct
//  content based on the user's selected AppMode.
//
//  - `.cycle`    → CycleCalendarView (standard period tracking calendar)
//  - `.pregnant` → WeekByWeekView (pregnancy timeline)
//  - `.ttc`      → CycleCalendarView with a fertile-window banner
//

import SwiftUI

// MARK: - CalendarContainerView

/// Routes the Calendar tab to the correct view based on `appMode`.
///
/// Mirrors the pattern established by `HomeContainerView`. The switch
/// is reactive — changing mode in Settings immediately transitions the
/// content without relaunching.
struct CalendarContainerView: View {

    // MARK: - Environment

    @Environment(AppDependencies.self) private var dependencies

    // MARK: - Body

    var body: some View {
        switch dependencies.settingsManager.appMode {
        case .cycle:
            CycleCalendarView(
                viewModel: CalendarViewModel(
                    cycleRepository: dependencies.cycleRepository,
                    predictionService: dependencies.cyclePredictionService
                )
            )

        case .pregnant:
            pregnancyCalendarContent

        case .ttc:
            ttcCalendarContent
        }
    }

    // MARK: - Pregnancy Calendar

    /// Shows the week-by-week pregnancy timeline as the calendar view
    /// in pregnancy mode. Reads the current week from PregnancyViewModel.
    private var pregnancyCalendarContent: some View {
        let vm = PregnancyViewModel(repository: dependencies.pregnancyRepository)
        return WeekByWeekView(currentWeek: vm.currentWeek)
    }

    // MARK: - TTC Calendar

    /// Shows the standard cycle calendar with a fertile-window status
    /// banner at the top. TTC users still track cycles, so the calendar
    /// is the same — the banner adds TTC-specific context.
    private var ttcCalendarContent: some View {
        let ttcVM = TTCViewModel(dependencies: dependencies)
        return VStack(spacing: 0) {
            TTCFertileBanner(viewModel: ttcVM)

            CycleCalendarView(
                viewModel: CalendarViewModel(
                    cycleRepository: dependencies.cycleRepository,
                    predictionService: dependencies.cyclePredictionService
                )
            )
        }
        .onAppear { ttcVM.refresh() }
    }
}

// MARK: - TTCFertileBanner

/// A compact banner shown above the calendar in TTC mode that
/// communicates the user's current fertile-window status at a glance.
private struct TTCFertileBanner: View {

    let viewModel: TTCViewModel

    @Environment(\.currentCyclePhase) private var phase

    var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(bannerIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(bannerTitle)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(bannerSubtitle)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            Spacer()

            // OPK trend badge
            if viewModel.opkTrend == .positive {
                BloomChip(
                    "Peak",
                    icon: BloomIcons.starFilled,
                    color: BloomHerTheme.Colors.sageGreen,
                    isSelected: true,
                    action: {}
                )
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(bannerColor.opacity(0.08))
    }

    // MARK: - Banner Content

    private var bannerIcon: String {
        if viewModel.isInFertileWindow { return BloomIcons.heartFilled }
        if viewModel.isOvulationDay { return BloomIcons.starFilled }
        return BloomIcons.calendarClock
    }

    private var bannerColor: Color {
        if viewModel.isInFertileWindow || viewModel.isOvulationDay {
            return BloomHerTheme.Colors.sageGreen
        }
        return BloomHerTheme.Colors.accentLavender
    }

    private var bannerTitle: String {
        if viewModel.isOvulationDay { return "Ovulation Day" }
        if viewModel.isInFertileWindow { return "Fertile Window" }
        let days = viewModel.daysUntilFertileWindow
        if days > 0 && days < 30 {
            return "\(days) day\(days == 1 ? "" : "s") until fertile window"
        }
        return "Trying to Conceive"
    }

    private var bannerSubtitle: String {
        if viewModel.isOvulationDay {
            return "Peak fertility — best chance today"
        }
        if viewModel.isInFertileWindow {
            return "High chance of conception"
        }
        return "Track your cycle to predict your fertile window"
    }
}

// MARK: - Preview

#Preview("Calendar Container — Cycle") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .cycle
    return NavigationStack {
        CalendarContainerView()
    }
    .environment(deps)
}

#Preview("Calendar Container — Pregnant") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .pregnant
    return NavigationStack {
        CalendarContainerView()
    }
    .environment(deps)
}

#Preview("Calendar Container — TTC") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .ttc
    return NavigationStack {
        CalendarContainerView()
    }
    .environment(deps)
}
