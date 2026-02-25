//
//  InsightsContainerView.swift
//  BloomHer
//
//  Mode-aware wrapper that routes the Insights tab to the correct
//  content based on the user's selected AppMode.
//
//  - `.cycle`    → InsightsTabView (cycle analytics)
//  - `.pregnant` → Pregnancy insights (weight, kicks, appointments)
//  - `.ttc`      → TTC insights (fertility trends, OPK, BBT)
//

import SwiftUI

// MARK: - InsightsContainerView

/// Routes the Insights tab to the correct analytics view based on `appMode`.
struct InsightsContainerView: View {

    // MARK: - Environment

    @Environment(AppDependencies.self) private var dependencies

    // MARK: - Body

    var body: some View {
        switch dependencies.settingsManager.appMode {
        case .cycle:
            InsightsTabView(dependencies: dependencies)

        case .pregnant:
            PregnancyInsightsView(dependencies: dependencies)

        case .ttc:
            TTCInsightsView(dependencies: dependencies)
        }
    }
}

// MARK: - PregnancyInsightsView

/// Insights tab content for pregnancy mode. Shows weight trends,
/// kick count stats, appointment timeline, and pregnancy progress.
private struct PregnancyInsightsView: View {

    @State private var viewModel: PregnancyViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: PregnancyViewModel(
            repository: dependencies.pregnancyRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                progressCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 0)

                statsGrid
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)

                weightTrendCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)

                appointmentsCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 3)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Pregnancy Insights")
        .onAppear { viewModel.refresh() }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        BloomCard(isPhaseAware: false) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Pregnancy Progress")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Week \(viewModel.currentWeek) of 40 \u{2022} \(viewModel.trimesterLabel)")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    Spacer()
                    Text("\(Int(viewModel.pregnancyProgress * 100))%")
                        .font(BloomHerTheme.Typography.title2)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }

                BloomProgressBar(
                    progress: viewModel.pregnancyProgress,
                    color: BloomHerTheme.Colors.primaryRose,
                    height: 10,
                    showLabel: false
                )

                if viewModel.daysUntilDue > 0 {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.calendarClock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Due: \(viewModel.dueDateFormatted) (\(viewModel.daysUntilDue) days)")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: BloomHerTheme.Spacing.sm
        ) {
            pregnancyStat(
                label: "Today's Kicks",
                value: "\(viewModel.todaysKickCount)",
                icon: BloomIcons.handTap,
                color: BloomHerTheme.Colors.accentPeach
            )
            pregnancyStat(
                label: "Weight",
                value: viewModel.latestWeight.map { String(format: "%.1f kg", $0) } ?? "–",
                icon: BloomIcons.scales,
                color: BloomHerTheme.Colors.sageGreen
            )
            pregnancyStat(
                label: "Appointments",
                value: "\(viewModel.upcomingAppointments.count)",
                icon: BloomIcons.stethoscope,
                color: BloomHerTheme.Colors.accentLavender
            )
        }
    }

    private func pregnancyStat(label: String, value: String, icon: String, color: Color) -> some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(value)
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .contentTransition(.numericText())
                Text(label)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
        }
    }

    // MARK: - Weight Trend Card

    private var weightTrendCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.chartLine)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Weight Trend")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                if viewModel.weightEntries.isEmpty {
                    emptyPrompt(
                        icon: BloomIcons.scales,
                        message: "Log your weight to see trends over your pregnancy"
                    )
                } else {
                    // Show last 5 entries as a simple list
                    ForEach(viewModel.weightEntries.suffix(5), id: \.date) { entry in
                        HStack {
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            Spacer()
                            Text(String(format: "%.1f kg", entry.weightKg))
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Appointments Card

    private var appointmentsCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.calendarClock)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Upcoming Appointments")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                if viewModel.upcomingAppointments.isEmpty {
                    emptyPrompt(
                        icon: BloomIcons.stethoscope,
                        message: "No upcoming appointments. Add one from your pregnancy dashboard."
                    )
                } else {
                    ForEach(viewModel.upcomingAppointments.prefix(3), id: \.id) { appt in
                        HStack(spacing: BloomHerTheme.Spacing.sm) {
                            Circle()
                                .fill(BloomHerTheme.Colors.accentLavender)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(appt.title)
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                Text(appt.date.formatted(date: .long, time: .shortened))
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Empty Prompt

    private func emptyPrompt(icon: String, message: String) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text(message)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xs)
    }
}

// MARK: - TTCInsightsView

/// Insights tab content for TTC mode. Shows fertility trends,
/// OPK history, BBT chart summary, and cycle attempt stats.
private struct TTCInsightsView: View {

    @State private var viewModel: TTCViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: TTCViewModel(dependencies: dependencies))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                fertilityOverviewCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 0)

                statsGrid
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)

                opkHistoryCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)

                bbtSummaryCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 3)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("TTC Insights")
        .onAppear { viewModel.refresh() }
    }

    // MARK: - Fertility Overview

    private var fertilityOverviewCard: some View {
        BloomCard(isPhaseAware: false) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Fertility Overview")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Cycle \(viewModel.cycleCount + 1) of trying")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    Spacer()
                    fertileStatusBadge
                }

                if let start = viewModel.fertileWindowStart,
                   let end = viewModel.fertileWindowEnd {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.calendar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text("Fertile window: \(start.formatted(.dateTime.month(.abbreviated).day())) – \(end.formatted(.dateTime.month(.abbreviated).day()))")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                if let ovDate = viewModel.estimatedOvulationDate {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.starFilled)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text("Estimated ovulation: \(ovDate.formatted(.dateTime.month(.abbreviated).day()))")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var fertileStatusBadge: some View {
        Group {
            if viewModel.isOvulationDay {
                statusChip(text: "Ovulation", color: BloomHerTheme.Colors.accentPeach)
            } else if viewModel.isInFertileWindow {
                statusChip(text: "Fertile", color: BloomHerTheme.Colors.sageGreen)
            } else {
                statusChip(text: viewModel.currentPhase.displayName, color: BloomColors.color(for: viewModel.currentPhase))
            }
        }
    }

    private func statusChip(text: String, color: Color) -> some View {
        Text(text)
            .font(BloomHerTheme.Typography.caption2)
            .foregroundStyle(color)
            .padding(.horizontal, BloomHerTheme.Spacing.xs)
            .padding(.vertical, BloomHerTheme.Spacing.xxs)
            .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: BloomHerTheme.Spacing.sm
        ) {
            ttcStat(
                label: "Cycles Trying",
                value: "\(viewModel.cycleCount)",
                icon: BloomIcons.refresh,
                color: BloomHerTheme.Colors.primaryRose
            )
            ttcStat(
                label: "OPK Tests",
                value: "\(viewModel.recentOPKResults.count)",
                icon: BloomIcons.colorDropper,
                color: BloomHerTheme.Colors.accentPeach
            )
            ttcStat(
                label: "BBT Entries",
                value: "\(viewModel.recentBBTEntries.count)",
                icon: BloomIcons.thermometer,
                color: BloomHerTheme.Colors.sageGreen
            )
        }
    }

    private func ttcStat(label: String, value: String, icon: String, color: Color) -> some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(value)
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .contentTransition(.numericText())
                Text(label)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
        }
    }

    // MARK: - OPK History Card

    private var opkHistoryCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.colorDropper)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("OPK History")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    opkTrendBadge
                }

                if viewModel.recentOPKResults.isEmpty {
                    emptyPrompt(
                        icon: BloomIcons.colorDropper,
                        message: "Log OPK tests to see your LH surge patterns"
                    )
                } else {
                    // Show last 7 results
                    ForEach(viewModel.recentOPKResults.suffix(7), id: \.date) { result in
                        HStack {
                            Text(result.date.formatted(date: .abbreviated, time: .omitted))
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            Spacer()
                            opkLevelIndicator(result.result)
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var opkTrendBadge: some View {
        Group {
            switch viewModel.opkTrend {
            case .positive:
                statusChip(text: "Peak", color: BloomHerTheme.Colors.sageGreen)
            case .rising:
                statusChip(text: "Rising", color: BloomHerTheme.Colors.accentPeach)
            case .stable:
                statusChip(text: "Low", color: BloomHerTheme.Colors.textTertiary)
            }
        }
    }

    private func opkLevelIndicator(_ level: OPKLevel) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            Circle()
                .fill(opkColor(for: level))
                .frame(width: 8, height: 8)
            Text(level.displayName)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(opkColor(for: level))
        }
    }

    private func opkColor(for level: OPKLevel) -> Color {
        switch level {
        case .positive: return BloomHerTheme.Colors.sageGreen
        case .faint:    return BloomHerTheme.Colors.accentPeach
        case .negative: return BloomHerTheme.Colors.textTertiary
        }
    }

    // MARK: - BBT Summary Card

    private var bbtSummaryCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.thermometer)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("BBT Summary")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    if viewModel.hasThermalShift {
                        statusChip(text: "Shift detected", color: BloomHerTheme.Colors.sageGreen)
                    }
                }

                if viewModel.recentBBTEntries.isEmpty {
                    emptyPrompt(
                        icon: BloomIcons.thermometer,
                        message: "Log daily BBT readings to detect your thermal shift"
                    )
                } else {
                    HStack(spacing: BloomHerTheme.Spacing.lg) {
                        if let coverline = viewModel.coverlineTemperature {
                            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                                Text(String(format: "%.2f\u{00B0}C", coverline))
                                    .font(BloomHerTheme.Typography.title3)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                Text("Coverline")
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                        }

                        if let latest = viewModel.recentBBTEntries.last {
                            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                                Text(String(format: "%.2f\u{00B0}C", latest.temperatureCelsius))
                                    .font(BloomHerTheme.Typography.title3)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                Text("Latest")
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                        }

                        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                            Text("\(viewModel.recentBBTEntries.count)")
                                .font(BloomHerTheme.Typography.title3)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            Text("Readings")
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Empty Prompt

    private func emptyPrompt(icon: String, message: String) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text(message)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xs)
    }
}

// MARK: - Preview

#Preview("Insights Container — Cycle") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .cycle
    return NavigationStack {
        InsightsContainerView()
    }
    .environment(deps)
}

#Preview("Insights Container — Pregnant") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .pregnant
    return NavigationStack {
        InsightsContainerView()
    }
    .environment(deps)
}

#Preview("Insights Container — TTC") {
    let deps = AppDependencies.preview()
    deps.settingsManager.appMode = .ttc
    return NavigationStack {
        InsightsContainerView()
    }
    .environment(deps)
}
