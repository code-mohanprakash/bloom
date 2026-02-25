//
//  CycleLengthStatsBar.swift
//  BloomHer
//
//  A horizontally scrollable stats bar that surfaces key cycle prediction
//  figures below the calendar grid. Each stat is displayed as a labeled pill
//  with a phase-tinted accent.
//

import SwiftUI

// MARK: - CycleLengthStatsBar

/// A compact horizontally scrollable bar of cycle statistics pills.
///
/// Displays average cycle length, average period length, and the predicted
/// next period start date, all derived from the provided `CyclePrediction`.
/// A confidence badge adapts the predicted-next pill's color.
///
/// ```swift
/// CycleLengthStatsBar(prediction: viewModel.prediction)
/// ```
public struct CycleLengthStatsBar: View {

    // MARK: Input

    /// The current cycle prediction supplying all stats.
    let prediction: CyclePrediction

    // MARK: Environment

    @Environment(\.currentCyclePhase) private var phase

    // MARK: Body

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                statPill(
                    icon: BloomIcons.refresh,
                    label: "Avg Cycle",
                    value: "\(prediction.predictedCycleLength) days",
                    color: BloomHerTheme.Colors.primaryRose
                )

                divider

                statPill(
                    icon: BloomIcons.drop,
                    label: "Avg Period",
                    value: "\(prediction.predictedPeriodLength) days",
                    color: BloomColors.menstrual
                )

                divider

                statPill(
                    icon: BloomIcons.calendar,
                    label: "Next Period",
                    value: nextPeriodLabel,
                    color: nextPeriodColor
                )

                if prediction.isIrregular {
                    divider

                    statPill(
                        icon: BloomIcons.warning,
                        label: "Pattern",
                        value: "Irregular",
                        color: BloomHerTheme.Colors.warning
                    )
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.xs)
        }
    }

    // MARK: Stat Pill

    @ViewBuilder
    private func statPill(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 11, height: 11)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)

                Text(value)
                    .font(BloomHerTheme.Typography.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
        }
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xxs + 2)
        .background(
            Capsule()
                .fill(color.opacity(0.10))
        )
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.20), lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(BloomHerTheme.Colors.textTertiary.opacity(0.30))
            .frame(width: 1, height: 28)
    }

    // MARK: Helpers

    private var nextPeriodLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = .current
        return formatter.string(from: prediction.predictedNextStart)
    }

    private var nextPeriodColor: Color {
        switch prediction.confidence {
        case .high:   return BloomColors.menstrual
        case .medium: return BloomHerTheme.Colors.warning
        case .low:    return BloomHerTheme.Colors.textSecondary
        }
    }
}

// MARK: - Preview

#Preview("Cycle Length Stats Bar") {
    let prediction = CyclePrediction(
        predictedNextStart: Calendar.current.date(byAdding: .day, value: 9, to: Date()) ?? Date(),
        predictedPeriodLength: 5,
        predictedCycleLength: 28,
        estimatedOvulationDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        fertileWindowStart: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
        fertileWindowEnd: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        confidence: .high,
        isIrregular: false
    )

    return VStack(spacing: BloomHerTheme.Spacing.xl) {
        Text("Cycle Stats")
            .font(BloomHerTheme.Typography.headline)
            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, BloomHerTheme.Spacing.md)

        BloomCard {
            CycleLengthStatsBar(prediction: prediction)
                .padding(.horizontal, -BloomHerTheme.Spacing.md)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
    }
    .padding(.vertical, BloomHerTheme.Spacing.xl)
    .background(BloomHerTheme.Colors.background)
    .environment(\.currentCyclePhase, .follicular)
}
