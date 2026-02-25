//
//  OPKLoggingView.swift
//  BloomHer
//
//  OPK (Ovulation Prediction Kit) test-result logging interface.
//  Color-coded level selector, date picker, history timeline, OPK tips,
//  and pattern-recognition messaging.
//

import SwiftUI
import Charts

// MARK: - OPKLoggingView

struct OPKLoggingView: View {

    // MARK: State

    let viewModel: TTCViewModel

    @State private var selectedDate:  Date     = Date()
    @State private var selectedLevel: OPKLevel = .negative
    @State private var savedAnimation: Bool    = false
    @State private var showTips:       Bool    = false
    @Environment(\.dismiss) private var dismiss

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    trendMessageCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 0)

                    logEntrySection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)

                    historySection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 2)

                    opkTipsCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 3)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("OPK Tracker")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Trend Message Card

    private var trendMessageCard: some View {
        BloomCard(isPhaseAware: true) {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(viewModel.opkTrend.color.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(viewModel.opkTrend.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("OPK Pattern")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(viewModel.opkTrend.displayMessage)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Log Entry Section

    private var logEntrySection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("Log OPK Result")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                BloomDatePicker(
                    label: "Test Date",
                    date: $selectedDate,
                    displayedComponents: .date,
                    range: pastYearRange
                )

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Result")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    opkLevelGrid
                }

                // Photo placeholder
                photoPlaceholder

                // Save button
                BloomButton(
                    "Save Result",
                    style: .primary,
                    icon: savedAnimation ? BloomIcons.checkmarkCircle : BloomIcons.plus,
                    isFullWidth: true
                ) {
                    saveEntry()
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var opkLevelGrid: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ForEach(OPKLevel.allCases, id: \.self) { level in
                opkLevelButton(level: level)
            }
        }
    }

    private func opkLevelButton(level: OPKLevel) -> some View {
        let isSelected = selectedLevel == level
        return Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selectedLevel = level
            }
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                // Color swatch
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .fill(level.color)
                    .frame(width: 6)

                Image(level.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isSelected ? .white : level.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(isSelected ? .white : BloomHerTheme.Colors.textPrimary)
                    Text(opkLevelDescription(level))
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.85) : BloomHerTheme.Colors.textTertiary)
                }

                Spacer()

                if isSelected {
                    Image(BloomIcons.checkmarkCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                }
            }
            .padding(BloomHerTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .fill(isSelected ? level.color : BloomHerTheme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .strokeBorder(isSelected ? level.color : level.color.opacity(0.3), lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    private var photoPlaceholder: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.background)
                .frame(width: 72, height: 72)
                .overlay(
                    VStack(spacing: 4) {
                        Image(BloomIcons.cameraPlus)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        Text("Photo\n(soon)")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                        .strokeBorder(BloomHerTheme.Colors.textTertiary.opacity(0.3), lineWidth: 1, antialiased: true)
                )

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("Strip Photo Analysis")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("Coming soon — tap to add a photo of your test strip for automatic result detection.")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("Recent History")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                if viewModel.recentOPKResults.isEmpty {
                    emptyHistoryView
                } else {
                    opkHistoryChart
                    historyList
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var emptyHistoryView: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.chartBar)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text("No OPK results logged yet.\nStart testing daily from cycle day 10.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(BloomHerTheme.Spacing.lg)
    }

    private var opkHistoryChart: some View {
        let results = Array(viewModel.recentOPKResults.suffix(14))
        let levelValues: [OPKLevel: Double] = [.negative: 0.2, .faint: 0.6, .positive: 1.0]

        return Chart(results) { result in
            BarMark(
                x: .value("Date", result.date, unit: .day),
                y: .value("Level", levelValues[result.result] ?? 0)
            )
            .foregroundStyle(result.result.color)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 3)) { value in
                AxisValueLabel(format: .dateTime.day())
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .chartYAxis(.hidden)
        .frame(height: 80)
    }

    private var historyList: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            ForEach(Array(viewModel.recentOPKResults.suffix(5).reversed())) { result in
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Circle()
                        .fill(result.result.color)
                        .frame(width: 10, height: 10)
                    Text(result.date, style: .date)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Spacer()
                    Image(result.result.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(result.result.displayName)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }
                .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                if result.id != viewModel.recentOPKResults.suffix(5).reversed().first?.id {
                    Divider()
                }
            }
        }
    }

    // MARK: - OPK Tips Card

    private var opkTipsCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.sparkles)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("OPK Testing Tips")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                let tips: [(icon: String, text: String)] = [
                    (BloomIcons.clock, "Test at the same time each day — early afternoon is ideal, not first thing in the morning."),
                    (BloomIcons.drop, "Avoid excessive fluids 2 hours before testing to prevent diluted results."),
                    (BloomIcons.calendar, "Start testing from cycle day 10 for a 28-day cycle; adjust for your cycle length."),
                    (BloomIcons.refresh, "Test twice daily (morning + afternoon) when approaching your fertile window."),
                    (BloomIcons.target, "A positive result means the test line is as dark as or darker than the control line."),
                ]

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                            Image(tip.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .frame(width: 20)
                            Text(tip.text)
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Actions

    private func saveEntry() {
        viewModel.saveOPK(date: selectedDate, level: selectedLevel)
        withAnimation(BloomHerTheme.Animation.quick) {
            savedAnimation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(BloomHerTheme.Animation.quick) {
                savedAnimation = false
            }
        }
    }

    // MARK: - Helpers

    private var pastYearRange: ClosedRange<Date> {
        let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return start...Date()
    }

    private func opkLevelDescription(_ level: OPKLevel) -> String {
        switch level {
        case .negative: return "LH below surge threshold — not yet"
        case .faint:    return "LH rising — surge approaching"
        case .positive: return "LH surge detected — ovulation 24–36 hrs"
        }
    }
}

// MARK: - Preview

#Preview("OPK Logging") {
    OPKLoggingView(viewModel: {
        let vm = TTCViewModel(dependencies: AppDependencies.preview())
        vm.refresh()
        return vm
    }())
    .environment(\.currentCyclePhase, .follicular)
}
