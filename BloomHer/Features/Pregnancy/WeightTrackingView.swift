//
//  WeightTrackingView.swift
//  BloomHer
//
//  Weight logging and charting view with a Swift Charts line graph,
//  healthy range overlay, and entry history.
//

import SwiftUI
import Charts

// MARK: - WeightTrackingView

struct WeightTrackingView: View {

    // MARK: State

    @State private var viewModel: PregnancyViewModel
    @State private var showAddEntry: Bool = false
    @State private var chartTimeframe: Int = 0  // 0 = Weekly, 1 = Monthly
    @State private var newWeightKg: String = ""
    @State private var newWeightDate: Date = Date()
    @State private var weightInputFocused: Bool = false

    // MARK: Init

    init(viewModel: PregnancyViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: Computed

    private var filteredEntries: [WeightEntry] {
        guard !viewModel.weightEntries.isEmpty else { return [] }
        let cutoff: Date
        if chartTimeframe == 0 {
            cutoff = Calendar.current.date(byAdding: .weekOfYear, value: -12, to: Date()) ?? Date()
        } else {
            cutoff = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        }
        return viewModel.weightEntries.filter { $0.date >= cutoff }
    }

    private var weightTrend: WeightTrend {
        guard filteredEntries.count >= 2 else { return .stable }
        let recent = filteredEntries.suffix(3).map { $0.weightKg }
        let avg = recent.reduce(0, +) / Double(recent.count)
        let prev = filteredEntries.dropLast(3).suffix(3).map { $0.weightKg }
        guard !prev.isEmpty else { return .stable }
        let prevAvg = prev.reduce(0, +) / Double(prev.count)
        let diff = avg - prevAvg
        if diff > 0.2 { return .increasing }
        if diff < -0.2 { return .decreasing }
        return .stable
    }

    private var yAxisRange: ClosedRange<Double> {
        guard !filteredEntries.isEmpty else { return 50...100 }
        let weights = filteredEntries.map { $0.weightKg }
        let minW = (weights.min() ?? 50) - 3
        let maxW = (weights.max() ?? 100) + 3
        return minW...maxW
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                currentWeightHeader
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                chartSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                addEntryButton
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                historySection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Weight Tracker")
        .sheet(isPresented: $showAddEntry, onDismiss: {
            viewModel.loadWeightHistory()
        }) {
            addWeightSheet
                .bloomSheet(detents: [.medium])
        }
        .task {
            viewModel.loadWeightHistory()
        }
    }

    // MARK: - Current Weight Header

    private var currentWeightHeader: some View {
        BloomCard {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Current Weight")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    if let weight = viewModel.latestWeight {
                        HStack(alignment: .firstTextBaseline, spacing: BloomHerTheme.Spacing.xxs) {
                            Text(String(format: "%.1f", weight))
                                .font(BloomHerTheme.Typography.heroNumber)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                .contentTransition(.numericText())
                            Text("kg")
                                .font(BloomHerTheme.Typography.title3)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }
                    } else {
                        Text("No entries yet")
                            .font(BloomHerTheme.Typography.title2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }

                    if viewModel.weightEntries.count > 1 {
                        let first = viewModel.weightEntries.first!.weightKg
                        let last = viewModel.latestWeight!
                        let diff = last - first
                        Text(String(format: "%+.1f kg since start", diff))
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                trendIndicator
            }
        }
    }

    private var trendIndicator: some View {
        VStack(spacing: BloomHerTheme.Spacing.xxs) {
            Image(weightTrend.icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(weightTrend.color)
            Text(weightTrend.label)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    BloomHeader(title: "Weight Over Time")
                    Spacer()
                    BloomSegmentedControl(
                        options: ["12 Wks", "6 Mo"],
                        selectedIndex: $chartTimeframe
                    )
                    .fixedSize()
                }

                if filteredEntries.count < 2 {
                    emptyChartPlaceholder
                } else {
                    weightChart
                }
            }
        }
    }

    private var weightChart: some View {
        Chart {
            // Healthy range shading (approx 0.4–1.8 kg/week gain for second/third trimester)
            if filteredEntries.count >= 2 {
                let startWeight = filteredEntries.first!.weightKg
                let startDate = filteredEntries.first!.date
                let endDate = filteredEntries.last!.date

                RectangleMark(
                    xStart: .value("Start", startDate),
                    xEnd: .value("End", endDate),
                    yStart: .value("Low", startWeight),
                    yEnd: .value("High", startWeight + weeksBetween(startDate, endDate) * 1.8)
                )
                .foregroundStyle(BloomHerTheme.Colors.sageGreen.opacity(0.12))
            }

            // Area fill under line
            ForEach(filteredEntries) { entry in
                AreaMark(
                    x: .value("Date", entry.date),
                    yStart: .value("Base", yAxisRange.lowerBound),
                    yEnd: .value("Weight", entry.weightKg)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BloomHerTheme.Colors.primaryRose.opacity(0.2),
                            BloomHerTheme.Colors.primaryRose.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            // Line
            ForEach(filteredEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight (kg)", entry.weightKg)
                )
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
            }

            // Point marks
            ForEach(filteredEntries) { entry in
                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight (kg)", entry.weightKg)
                )
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                .symbolSize(36)
            }
        }
        .chartYScale(domain: yAxisRange)
        .chartXAxis {
            AxisMarks(values: .stride(by: chartTimeframe == 0 ? .weekOfYear : .month)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                AxisValueLabel(format: chartTimeframe == 0 ? .dateTime.month().day() : .dateTime.month())
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(String(format: "%.0f", v))
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
            }
        }
        .frame(height: 200)
        .animation(BloomHerTheme.Animation.gentle, value: chartTimeframe)
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.chartLine)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text("Log at least 2 weights to see your chart")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }

    // MARK: - Add Entry Button

    private var addEntryButton: some View {
        BloomButton("Log Weight", style: .primary, icon: BloomIcons.plus, isFullWidth: true) {
            newWeightKg = viewModel.latestWeight.map { String(format: "%.1f", $0) } ?? ""
            newWeightDate = Date()
            showAddEntry = true
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "History")

            if viewModel.weightEntries.isEmpty {
                BloomCard {
                    HStack {
                        Image(BloomIcons.scales)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("No weight entries yet")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(viewModel.weightEntries.reversed()) { entry in
                        WeightEntryRow(entry: entry)
                    }
                }
            }
        }
    }

    // MARK: - Add Weight Sheet

    private var addWeightSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.xl) {
                    // Illustration
                    Image(BloomIcons.scales)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .padding(.top, BloomHerTheme.Spacing.xl)

                    BloomCard {
                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                            Text("Weight (kg)")
                                .font(BloomHerTheme.Typography.headline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                            TextField("e.g. 72.5", text: $newWeightKg)
                                .font(BloomHerTheme.Typography.heroNumber)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                                .tint(BloomHerTheme.Colors.primaryRose)
                                .padding(BloomHerTheme.Spacing.sm)
                                .background(
                                    BloomHerTheme.Colors.background,
                                    in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium)
                                )
                        }
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    BloomCard {
                        BloomDatePicker(
                            label: "Date",
                            date: $newWeightDate,
                            range: Calendar.current.date(byAdding: .year, value: -1, to: Date())!...Date()
                        )
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    BloomButton("Save Entry", style: .primary, icon: BloomIcons.checkmark, isFullWidth: true) {
                        saveWeightEntry()
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .disabled(Double(newWeightKg) == nil)
                }
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Log Weight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddEntry = false }
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
    }

    // MARK: - Actions

    private func saveWeightEntry() {
        guard let kg = Double(newWeightKg.replacingOccurrences(of: ",", with: ".")) else { return }
        let entry = WeightEntry(date: newWeightDate, weightKg: kg)
        entry.pregnancy = viewModel.pregnancyProfile
        viewModel.saveWeightEntry(entry)
        BloomHerTheme.Haptics.success()
        showAddEntry = false
    }

    private func weeksBetween(_ start: Date, _ end: Date) -> Double {
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        return Double(days) / 7.0
    }
}

// MARK: - WeightTrend

private enum WeightTrend {
    case increasing, decreasing, stable

    var icon: String {
        switch self {
        case .increasing: return BloomIcons.chevronUp
        case .decreasing: return BloomIcons.chevronDown
        case .stable:     return BloomIcons.chevronRight
        }
    }

    var color: Color {
        switch self {
        case .increasing: return BloomHerTheme.Colors.accentPeach
        case .decreasing: return BloomColors.info
        case .stable:     return BloomHerTheme.Colors.sageGreen
        }
    }

    var label: String {
        switch self {
        case .increasing: return "Gaining"
        case .decreasing: return "Losing"
        case .stable:     return "Stable"
        }
    }
}

// MARK: - WeightEntryRow

private struct WeightEntryRow: View {
    let entry: WeightEntry

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: entry.date)
    }

    var body: some View {
        BloomCard {
            HStack {
                Image(BloomIcons.scales)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(dateFormatted)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(String(format: "%.1f", entry.weightKg))
                        .font(BloomHerTheme.Typography.title3)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("kg")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Weight Tracking") {
    NavigationStack {
        WeightTrackingView(viewModel: PregnancyViewModel(repository: PreviewWeightRepo()))
    }
}

private class PreviewWeightRepo: PregnancyRepositoryProtocol {
    func fetchActivePregnancy() -> PregnancyProfile? { nil }
    func fetchAllPregnancies() -> [PregnancyProfile] { [] }
    func savePregnancy(_ pregnancy: PregnancyProfile) {}
    func deletePregnancy(_ pregnancy: PregnancyProfile) {}
    func fetchKickSessions(for pregnancy: PregnancyProfile) -> [KickSession] { [] }
    func saveKickSession(_ session: KickSession) {}
    func fetchContractions(for pregnancy: PregnancyProfile) -> [ContractionEntry] { [] }
    func saveContraction(_ contraction: ContractionEntry) {}
    func fetchWeightEntries(for pregnancy: PregnancyProfile) -> [WeightEntry] { [] }
    func saveWeightEntry(_ entry: WeightEntry) {}
    func fetchAppointments(for pregnancy: PregnancyProfile) -> [Appointment] { [] }
    func saveAppointment(_ appointment: Appointment) {}
    func deleteAppointment(_ appointment: Appointment) {}
}
