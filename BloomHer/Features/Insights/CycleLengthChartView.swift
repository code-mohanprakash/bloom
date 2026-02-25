//
//  CycleLengthChartView.swift
//  BloomHer
//
//  Shows cycle length over time as a Swift Charts line chart, an average
//  rule mark, and stat cards for average, shortest, longest, and prediction
//  confidence. Wrapped in BloomCard containers.
//

import SwiftUI
import Charts

// MARK: - CycleLengthChartView

/// Visualises how cycle length has varied over the user's tracked history.
///
/// - Line chart with data points, anchored to the average via a `RuleMark`.
/// - Below the chart: a grid of `InsightCardView` stat tiles.
/// - Empty state when fewer than 2 cycles are recorded.
struct CycleLengthChartView: View {

    // MARK: - State

    let viewModel: InsightsViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                chartCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 0)

                statsSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Cycle Length Trends")
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                // Section heading
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Cycle Length Over Time")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Each point represents one complete cycle")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                if viewModel.cycleLengthChartData().isEmpty {
                    emptyChartPlaceholder
                } else {
                    cycleLengthChart
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var cycleLengthChart: some View {
        let data    = viewModel.cycleLengthChartData()
        let average = viewModel.averageCycleLength
        let yMin    = max(14, (viewModel.shortestCycle > 0 ? viewModel.shortestCycle : 21) - 4)
        let yMax    = (viewModel.longestCycle > 0 ? viewModel.longestCycle : 35) + 4

        return Chart {
            // Area fill beneath the line for visual weight
            ForEach(data, id: \.index) { point in
                AreaMark(
                    x: .value("Cycle", point.index),
                    yStart: .value("Base", yMin),
                    yEnd:   .value("Days", point.length)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BloomHerTheme.Colors.primaryRose.opacity(0.25),
                            BloomHerTheme.Colors.primaryRose.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            // Main line
            ForEach(data, id: \.index) { point in
                LineMark(
                    x: .value("Cycle", point.index),
                    y: .value("Days", point.length)
                )
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
                .symbol {
                    Circle()
                        .fill(BloomHerTheme.Colors.primaryRose)
                        .frame(width: 7, height: 7)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1.5)
                        )
                }
            }

            // Average rule mark
            if average > 0 {
                RuleMark(y: .value("Average", average))
                    .foregroundStyle(BloomHerTheme.Colors.accentLavender.opacity(0.8))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .annotation(position: .trailing, alignment: .center) {
                        Text("avg")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary.opacity(0.3))
                AxisValueLabel()
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary.opacity(0.3))
                AxisValueLabel()
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .chartXAxisLabel("Cycle", alignment: .center)
        .chartYAxisLabel("Days", position: .leading)
        .chartYScale(domain: yMin...yMax)
        .frame(height: 220)
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.chartLine)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text("Not enough data yet")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            Text("Log at least two cycles to see your trend")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Summary")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            InsightCardView(
                icon:        BloomIcons.pulse,
                title:       "Average Cycle Length",
                value:       viewModel.averageCycleLength > 0
                                 ? "\(viewModel.averageCycleLength) days"
                                 : "–",
                subtitle:    "\(viewModel.totalCyclesTracked) cycle\(viewModel.totalCyclesTracked == 1 ? "" : "s") recorded",
                accentColor: BloomHerTheme.Colors.primaryRose
            )

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                InsightCardView(
                    icon:        BloomIcons.minusCircle,
                    title:       "Shortest",
                    value:       viewModel.shortestCycle > 0
                                     ? "\(viewModel.shortestCycle)d"
                                     : "–",
                    subtitle:    nil,
                    accentColor: BloomHerTheme.Colors.sageGreen
                )
                InsightCardView(
                    icon:        BloomIcons.arrowUpCircle,
                    title:       "Longest",
                    value:       viewModel.longestCycle > 0
                                     ? "\(viewModel.longestCycle)d"
                                     : "–",
                    subtitle:    nil,
                    accentColor: BloomHerTheme.Colors.accentPeach
                )
            }

            InsightCardView(
                icon:        confidenceIcon,
                title:       "Prediction Confidence",
                value:       viewModel.prediction?.confidence.displayName ?? "Low",
                subtitle:    viewModel.isIrregular
                                 ? "Your cycles show some variation"
                                 : "Based on your recent history",
                accentColor: confidenceColor
            )
        }
    }

    // MARK: - Helpers

    private var confidenceColor: Color {
        switch viewModel.prediction?.confidence {
        case .high:   return BloomHerTheme.Colors.sageGreen
        case .medium: return BloomHerTheme.Colors.accentPeach
        case .low, nil: return BloomHerTheme.Colors.warning
        }
    }

    private var confidenceIcon: String {
        switch viewModel.prediction?.confidence {
        case .high:   return BloomIcons.checkmarkSeal
        case .medium: return BloomIcons.checkmarkSeal
        case .low, nil: return BloomIcons.warning
        }
    }
}

// MARK: - Preview

#Preview("Cycle Length Chart") {
    NavigationStack {
        CycleLengthChartView(viewModel: InsightsViewModel(dependencies: AppDependencies.preview()))
    }
    .environment(\.currentCyclePhase, .follicular)
}
