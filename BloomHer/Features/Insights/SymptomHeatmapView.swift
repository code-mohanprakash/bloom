//
//  SymptomHeatmapView.swift
//  BloomHer
//
//  Displays symptom frequency as a horizontal bar chart for the top 10
//  symptoms, followed by a "Symptoms by Phase" breakdown where each cycle
//  phase card shows its top 3 symptoms.
//

import SwiftUI

// MARK: - SymptomHeatmapView

/// Visualises which symptoms the user experiences most often, and how they
/// distribute across the four cycle phases.
///
/// - Top section: horizontal frequency bars for the top 10 symptoms.
/// - Bottom section: per-phase `BloomCard` with top-3 symptom rows.
struct SymptomHeatmapView: View {

    // MARK: - State

    let viewModel: InsightsViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                frequencySection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 0)

                phaseSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Symptom Patterns")
    }

    // MARK: - Frequency Bar Chart

    private var frequencySection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Most Frequent Symptoms")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Top 10 across all logged days")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                if viewModel.symptomFrequencies.isEmpty {
                    emptySymptomPrompt
                } else {
                    symptomBars
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var symptomBars: some View {
        let maxCount = viewModel.symptomFrequencies.first?.count ?? 1

        return VStack(spacing: BloomHerTheme.Spacing.xs) {
            ForEach(
                Array(viewModel.symptomFrequencies.enumerated()),
                id: \.offset
            ) { index, entry in
                symptomBarRow(
                    symptom:  entry.symptom,
                    count:    entry.count,
                    maxCount: maxCount,
                    index:    index
                )
            }
        }
    }

    private func symptomBarRow(
        symptom:  Symptom,
        count:    Int,
        maxCount: Int,
        index:    Int
    ) -> some View {
        let ratio = maxCount > 0 ? Double(count) / Double(maxCount) : 0

        return HStack(spacing: BloomHerTheme.Spacing.sm) {
            // Icon
            Image(symptom.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 13)

            // Name
            Text(symptom.displayName)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(width: 130, alignment: .leading)
                .lineLimit(1)

            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(BloomHerTheme.Colors.primaryRose.opacity(0.10))
                    Capsule()
                        .fill(
                            BloomHerTheme.Colors.primaryRose
                                .opacity(0.35 + 0.65 * ratio)
                        )
                        .frame(width: geo.size.width * ratio)
                }
            }
            .frame(height: 10)

            // Count label
            Text("\(count)")
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .frame(width: 24, alignment: .trailing)
        }
    }

    private var emptySymptomPrompt: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.chartBar)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
            Text("No symptoms logged yet")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            Text("Start logging your daily symptoms to see patterns here")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BloomHerTheme.Spacing.lg)
    }

    // MARK: - Phase Breakdown

    private var phaseSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Symptoms by Phase")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            ForEach(CyclePhase.allCases, id: \.self) { phase in
                phaseSymptomCard(phase: phase)
                    .staggeredAppear(index: phaseIndex(phase) + 2)
            }
        }
    }

    private func phaseSymptomCard(phase: CyclePhase) -> some View {
        let phaseSymptoms = viewModel.symptomsByPhase[phase] ?? [:]
        let topThree = phaseSymptoms
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { (symptom: $0.key, count: $0.value) }

        return BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                // Phase header
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(phase.customImage ?? BloomIcons.phaseMenstrual)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text(phase.displayName)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(phaseSymptoms.values.reduce(0, +)) total")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }

                if topThree.isEmpty {
                    Text("No symptoms logged during this phase")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                } else {
                    Divider()
                        .background(phase.color.opacity(0.3))
                    VStack(spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(topThree, id: \.symptom) { entry in
                            phaseSymptomRow(
                                symptom: entry.symptom,
                                count:   entry.count,
                                phase:   phase
                            )
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private func phaseSymptomRow(symptom: Symptom, count: Int, phase: CyclePhase) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(symptom.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)

            Text(symptom.displayName)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Spacer()

            Text("\(count)x")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .padding(.horizontal, BloomHerTheme.Spacing.xs)
                .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                .background(phase.color.opacity(0.12),
                            in: Capsule())
        }
    }

    // MARK: - Helpers

    private func phaseIndex(_ phase: CyclePhase) -> Int {
        CyclePhase.allCases.firstIndex(of: phase) ?? 0
    }
}

// MARK: - Preview

#Preview("Symptom Heatmap") {
    NavigationStack {
        SymptomHeatmapView(viewModel: InsightsViewModel(dependencies: AppDependencies.preview()))
    }
    .environment(\.currentCyclePhase, .follicular)
}
