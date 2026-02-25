//
//  MoodPatternsView.swift
//  BloomHer
//
//  Shows mood patterns across the full cycle history: a horizontal frequency
//  bar chart of the top moods, a per-phase mood breakdown, and insight cards
//  surfacing the most and least common mood.
//

import SwiftUI

// MARK: - MoodPatternsView

/// Visualises how the user's emotional state varies across their cycle.
///
/// - Top section: horizontal bar chart of top-10 moods by frequency.
/// - Middle section: per-phase `BloomCard` showing top moods with emoji.
/// - Bottom section: two insight cards — most common and least common mood.
struct MoodPatternsView: View {

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

                insightSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Mood Analysis")
    }

    // MARK: - Frequency Bar Chart

    private var frequencySection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Your Mood Landscape")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Top moods across all logged days")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                if viewModel.moodFrequencies.isEmpty {
                    emptyMoodPrompt
                } else {
                    moodBars
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var moodBars: some View {
        let maxCount = viewModel.moodFrequencies.first?.count ?? 1

        return VStack(spacing: BloomHerTheme.Spacing.xs) {
            ForEach(
                Array(viewModel.moodFrequencies.enumerated()),
                id: \.offset
            ) { _, entry in
                moodBarRow(mood: entry.mood, count: entry.count, maxCount: maxCount)
            }
        }
    }

    private func moodBarRow(mood: Mood, count: Int, maxCount: Int) -> some View {
        let ratio   = maxCount > 0 ? Double(count) / Double(maxCount) : 0
        let barColor = BloomHerTheme.Colors.accentLavender

        return HStack(spacing: BloomHerTheme.Spacing.sm) {
            // Emoji
            Text(mood.emoji)
                .font(BloomHerTheme.Typography.callout)
                .frame(width: 24, alignment: .center)

            // Name
            Text(mood.displayName)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(width: 100, alignment: .leading)
                .lineLimit(1)

            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(barColor.opacity(0.10))
                    Capsule()
                        .fill(barColor.opacity(0.30 + 0.70 * ratio))
                        .frame(width: geo.size.width * ratio)
                }
            }
            .frame(height: 10)

            // Count
            Text("\(count)")
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .frame(width: 28, alignment: .trailing)
        }
    }

    private var emptyMoodPrompt: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.faceSmiling)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
            Text("No moods logged yet")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            Text("Log how you feel each day to uncover patterns")
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
            Text("Moods by Phase")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            ForEach(CyclePhase.allCases, id: \.self) { phase in
                phaseMoodCard(phase: phase)
                    .staggeredAppear(index: phaseIndex(phase) + 3)
            }
        }
    }

    private func phaseMoodCard(phase: CyclePhase) -> some View {
        let phaseMoods = viewModel.moodsByPhase[phase] ?? [:]
        let topThree = phaseMoods
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { (mood: $0.key, count: $0.value) }

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
                    Text(phase.emoji)
                        .font(BloomHerTheme.Typography.callout)
                }

                if topThree.isEmpty {
                    Text("No moods logged during this phase")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                } else {
                    Divider()
                        .background(phase.color.opacity(0.3))

                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        ForEach(topThree, id: \.mood) { entry in
                            phaseMoodChip(mood: entry.mood, count: entry.count, phase: phase)
                        }
                        Spacer()
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private func phaseMoodChip(mood: Mood, count: Int, phase: CyclePhase) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Text(mood.emoji)
                .font(BloomHerTheme.Typography.title3)
            Text(mood.displayName)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("\(count)x")
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .frame(minWidth: 64)
        .padding(.vertical, BloomHerTheme.Spacing.xs)
        .padding(.horizontal, BloomHerTheme.Spacing.xs)
        .background(phase.color.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous))
    }

    // MARK: - Insight Cards

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Key Insights")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            if let topMood = viewModel.moodFrequencies.first {
                InsightCardView(
                    icon:        topMood.mood.icon,
                    title:       "Most Common Mood",
                    value:       "\(topMood.mood.emoji) \(topMood.mood.displayName)",
                    subtitle:    "Logged \(topMood.count) time\(topMood.count == 1 ? "" : "s")",
                    accentColor: BloomHerTheme.Colors.accentLavender
                )
            }

            if viewModel.moodFrequencies.count > 1,
               let leastCommon = viewModel.moodFrequencies.last {
                InsightCardView(
                    icon:        leastCommon.mood.icon,
                    title:       "Least Common Mood",
                    value:       "\(leastCommon.mood.emoji) \(leastCommon.mood.displayName)",
                    subtitle:    "Logged \(leastCommon.count) time\(leastCommon.count == 1 ? "" : "s")",
                    accentColor: BloomHerTheme.Colors.accentPeach
                )
            }

            if viewModel.moodFrequencies.isEmpty {
                InsightCardView(
                    icon:        BloomIcons.faceSmiling,
                    title:       "Mood Data",
                    value:       "None yet",
                    subtitle:    "Log moods daily to generate insights",
                    accentColor: BloomHerTheme.Colors.textTertiary
                )
            }
        }
    }

    // MARK: - Helpers

    private func phaseIndex(_ phase: CyclePhase) -> Int {
        CyclePhase.allCases.firstIndex(of: phase) ?? 0
    }
}

// MARK: - Preview

#Preview("Mood Patterns") {
    NavigationStack {
        MoodPatternsView(viewModel: InsightsViewModel(dependencies: AppDependencies.preview()))
    }
    .environment(\.currentCyclePhase, .luteal)
}
