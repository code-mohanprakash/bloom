//
//  BBTChartView.swift
//  BloomHer
//
//  Basal Body Temperature charting using Swift Charts.
//  Features a line chart with point marks, a dashed coverline rule mark,
//  thermal-shift detection, cycle-phase background bands, and a log-entry sheet.
//

import SwiftUI
import Charts

// MARK: - BBTChartView

struct BBTChartView: View {

    // MARK: State

    let viewModel: TTCViewModel

    @State private var showAddSheet  = false
    @State private var addDate       = Date()
    @State private var tempInput     = ""
    @State private var addError: String? = nil
    @State private var savedPulse    = false
    @State private var chartRange    = ChartRange.twoWeeks
    @Environment(\.dismiss) private var dismiss

    // MARK: Chart Range

    enum ChartRange: String, CaseIterable {
        case week      = "7D"
        case twoWeeks  = "14D"
        case month     = "30D"

        var days: Int {
            switch self { case .week: return 7; case .twoWeeks: return 14; case .month: return 30 }
        }
    }

    // MARK: Computed Data

    private var chartEntries: [BBTEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -chartRange.days, to: Date()) ?? Date()
        return viewModel.recentBBTEntries.filter { $0.date >= cutoff }
    }

    private var yDomain: ClosedRange<Double> {
        guard !chartEntries.isEmpty else { return 36.0...37.5 }
        let temps = chartEntries.map(\.temperatureCelsius)
        let min   = (temps.min() ?? 36.0) - 0.15
        let max   = (temps.max() ?? 37.5) + 0.15
        return min...max
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    thermalShiftBanner
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 0)

                    chartSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)

                    if !viewModel.recentBBTEntries.isEmpty {
                        dataTable
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 2)
                    }

                    biphasicExplanationCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 3)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("BBT Chart")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        BloomHerTheme.Haptics.light()
                        showAddSheet = true
                    } label: {
                        Image(BloomIcons.plus)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addEntrySheet
                    .bloomSheet(detents: [.medium])
            }
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Thermal Shift Banner

    @ViewBuilder
    private var thermalShiftBanner: some View {
        if viewModel.hasThermalShift {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.thermometer)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Thermal Shift Detected")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("3+ temperatures above the coverline suggest ovulation has occurred.")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .fill(BloomHerTheme.Colors.sageGreen.opacity(0.12))
            )
        } else if let coverline = viewModel.coverlineTemperature {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.plusMinus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Coverline: \(coverline, specifier: "%.2f")°C")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("No thermal shift yet — keep tracking your temperature daily.")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .fill(BloomHerTheme.Colors.accentLavender.opacity(0.10))
            )
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Text("Temperature Chart")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    BloomSegmentedControl(
                        options: ChartRange.allCases.map(\.rawValue),
                        selectedIndex: Binding(
                            get: { ChartRange.allCases.firstIndex(of: chartRange) ?? 1 },
                            set: { chartRange = ChartRange.allCases[$0] }
                        )
                    )
                    .frame(width: 160)
                }

                if chartEntries.isEmpty {
                    emptyChartPlaceholder
                } else {
                    bbtChart
                    chartLegend
                }

                BloomButton("Log Temperature", style: .primary, icon: BloomIcons.thermometer, isFullWidth: true) {
                    showAddSheet = true
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.thermometer)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text("No temperatures logged yet")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            Text("Tap + to add your first BBT reading")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }

    private func pointColor(for entry: BBTEntry) -> Color {
        let coverline = viewModel.coverlineTemperature ?? 0
        if entry.temperatureCelsius > coverline + 0.2 {
            return BloomHerTheme.Colors.sageGreen
        }
        return BloomHerTheme.Colors.primaryRose
    }

    private var bbtChart: some View {
        Chart {
            fertileWindowMarks
            coverlineMarks
            temperatureLineMarks
            temperaturePointMarks
            ovulationAnnotationMarks
        }
        .chartYScale(domain: yDomain)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: chartRange == .week ? 1 : chartRange == .twoWeeks ? 2 : 5)) { value in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisValueLabel {
                    if let temp = value.as(Double.self) {
                        Text(String(format: "%.2f°", temp))
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary.opacity(0.3))
            }
        }
        .frame(height: 200)
    }

    // MARK: - Chart Content Helpers

    @ChartContentBuilder
    private var fertileWindowMarks: some ChartContent {
        if let fertileStart = viewModel.fertileWindowStart,
           let fertileEnd   = viewModel.fertileWindowEnd {
            RectangleMark(
                xStart: .value("Start", fertileStart),
                xEnd:   .value("End",   fertileEnd)
            )
            .foregroundStyle(BloomHerTheme.Colors.accentPeach.opacity(0.10))
        }
    }

    @ChartContentBuilder
    private var coverlineMarks: some ChartContent {
        if let coverline = viewModel.coverlineTemperature {
            RuleMark(y: .value("Coverline", coverline))
                .foregroundStyle(BloomHerTheme.Colors.accentLavender.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                .annotation(position: .leading, alignment: .center) {
                    Text("CL")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                }
        }
    }

    @ChartContentBuilder
    private var temperatureLineMarks: some ChartContent {
        ForEach(chartEntries) { entry in
            LineMark(
                x: .value("Date", entry.date, unit: .day),
                y: .value("°C", entry.temperatureCelsius)
            )
            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
        }
    }

    @ChartContentBuilder
    private var temperaturePointMarks: some ChartContent {
        ForEach(chartEntries) { entry in
            PointMark(
                x: .value("Date", entry.date, unit: .day),
                y: .value("°C", entry.temperatureCelsius)
            )
            .foregroundStyle(pointColor(for: entry))
            .symbolSize(40)
        }
    }

    @ChartContentBuilder
    private var ovulationAnnotationMarks: some ChartContent {
        if let ovDate = viewModel.estimatedOvulationDate {
            RuleMark(x: .value("Ovulation", ovDate, unit: .day))
                .foregroundStyle(BloomHerTheme.Colors.accentPeach.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [3, 3]))
                .annotation(position: .top) {
                    Image(BloomIcons.starFilled)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                }
        }
    }

    private var chartLegend: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            legendDot(color: BloomHerTheme.Colors.primaryRose, label: "BBT")
            legendDot(color: BloomHerTheme.Colors.sageGreen, label: "Above coverline")
            HStack(spacing: 4) {
                Rectangle()
                    .fill(BloomHerTheme.Colors.accentLavender.opacity(0.7))
                    .frame(width: 16, height: 1.5)
                    .overlay(
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle().fill(Color.clear).frame(width: 3, height: 1.5)
                            }
                        }
                    )
                Text("Coverline")
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            legendDot(color: BloomHerTheme.Colors.accentPeach.opacity(0.5), label: "Fertile zone")
        }
        .padding(.top, BloomHerTheme.Spacing.xxs)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
    }

    // MARK: - Data Table

    private var dataTable: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Recent Readings")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                ForEach(Array(viewModel.recentBBTEntries.suffix(7).reversed())) { entry in
                    HStack {
                        Text(entry.date, style: .date)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                        let isAbove = viewModel.coverlineTemperature.map { entry.temperatureCelsius > $0 + 0.2 } ?? false
                        Image(isAbove ? BloomIcons.arrowUpCircle : BloomIcons.minusCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 11, height: 11)
                            .foregroundStyle(isAbove ? BloomHerTheme.Colors.sageGreen : BloomHerTheme.Colors.textTertiary)
                        Text(String(format: "%.2f°C", entry.temperatureCelsius))
                            .font(BloomHerTheme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(isAbove ? BloomHerTheme.Colors.sageGreen : BloomHerTheme.Colors.textPrimary)
                            .monospacedDigit()
                            .frame(width: 70, alignment: .trailing)
                    }
                    .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                    Divider()
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Biphasic Explanation Card

    private var biphasicExplanationCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.pulse)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Understanding Your BBT")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                let points: [(String, String)] = [
                    (BloomIcons.moonStars, "Take your temperature every morning before getting up, after at least 3 hours of sleep."),
                    (BloomIcons.thermometer, "Use a basal thermometer (not a regular one) for the 0.1° precision BBT tracking requires."),
                    (BloomIcons.pulse, "Look for a biphasic pattern: lower temps in the follicular phase, a rise of 0.2–0.5°C after ovulation."),
                    (BloomIcons.calendarCheck, "The thermal shift confirms ovulation already happened — it confirms but doesn't predict."),
                ]
                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Image(point.0)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .frame(width: 20)
                        Text(point.1)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Add Entry Sheet

    private var addEntrySheet: some View {
        NavigationStack {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                VStack(spacing: BloomHerTheme.Spacing.lg) {
                    BloomDatePicker(
                        label: "Date",
                        date: $addDate,
                        displayedComponents: .date,
                        range: pastYearRange
                    )

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        BloomTextField(
                            placeholder: "e.g. 36.50",
                            icon: BloomIcons.thermometer,
                            text: $tempInput,
                            keyboardType: .decimalPad
                        )
                        if let error = addError {
                            Text(error)
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.error)
                        }
                        Text("Enter temperature in °C (e.g. 36.50)")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }

                BloomButton("Save Temperature", style: .primary, icon: savedPulse ? BloomIcons.checkmarkCircle : BloomIcons.thermometer, isFullWidth: true) {
                    commitBBTEntry()
                }
                Spacer()
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.background)
            .bloomNavigation("Log BBT")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
        }
    }

    // MARK: - Helpers

    private var pastYearRange: ClosedRange<Date> {
        let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return start...Date()
    }

    private func commitBBTEntry() {
        let cleaned = tempInput.replacingOccurrences(of: ",", with: ".")
        guard let temp = Double(cleaned) else {
            addError = "Please enter a valid decimal number."
            BloomHerTheme.Haptics.error()
            return
        }
        addError = nil
        viewModel.saveBBT(date: addDate, temperature: temp)
        if viewModel.errorMessage == nil {
            withAnimation(BloomHerTheme.Animation.quick) { savedPulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showAddSheet = false
                savedPulse   = false
                tempInput    = ""
            }
        } else {
            addError = viewModel.errorMessage
        }
    }
}

// MARK: - Preview

#Preview("BBT Chart") {
    BBTChartView(viewModel: {
        let vm = TTCViewModel(dependencies: AppDependencies.preview())
        vm.refresh()
        return vm
    }())
    .environment(\.currentCyclePhase, .luteal)
}
