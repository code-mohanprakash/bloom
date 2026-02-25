//
//  InsightCardView.swift
//  BloomHer
//
//  Reusable compact insight card used throughout the Insights tab.
//  Displays an icon in a colored circle, a title, a large numeric or
//  text value, and an optional supporting subtitle.
//

import SwiftUI

// MARK: - InsightCardView

/// A compact, horizontal insight card that highlights a single metric.
///
/// Used across `CycleLengthChartView`, `MoodPatternsView`, and any
/// view that needs to surface a key data point with a branded icon.
///
/// ```swift
/// InsightCardView(
///     icon:        "waveform.path.ecg",
///     title:       "Avg Length",
///     value:       "28 days",
///     subtitle:    "Based on 6 cycles",
///     accentColor: BloomHerTheme.Colors.primaryRose
/// )
/// ```
struct InsightCardView: View {

    // MARK: - Configuration

    /// BloomIcons asset name shown inside the accent-colored circle.
    let icon: String

    /// Small label displayed above the value.
    let title: String

    /// Prominent metric text — the headline number or phrase.
    let value: String

    /// Optional supporting detail shown beneath the value.
    let subtitle: String?

    /// Background color of the icon circle and value tint.
    let accentColor: Color

    // MARK: - Body

    var body: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                iconCircle
                metricStack
                Spacer(minLength: 0)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Subviews

    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(accentColor)
        }
    }

    private var metricStack: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
            Text(title)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)

            Text(value)
                .font(BloomHerTheme.Typography.title3)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .contentTransition(.numericText())

            if let subtitle {
                Text(subtitle)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Insight Card") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            InsightCardView(
                icon:        BloomIcons.pulse,
                title:       "Avg Cycle Length",
                value:       "28 days",
                subtitle:    "Based on 6 cycles",
                accentColor: BloomHerTheme.Colors.primaryRose
            )
            InsightCardView(
                icon:        BloomIcons.swap,
                title:       "Range",
                value:       "25 – 31 days",
                subtitle:    nil,
                accentColor: BloomHerTheme.Colors.accentLavender
            )
            InsightCardView(
                icon:        BloomIcons.checkmarkSeal,
                title:       "Prediction",
                value:       "High Confidence",
                subtitle:    "6+ cycles on record",
                accentColor: BloomHerTheme.Colors.sageGreen
            )
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .bloomBackground()
}
