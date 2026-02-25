//
//  SleepLogger.swift
//  BloomHer
//
//  A compact sleep duration and quality logger wrapped in a BloomCard.
//  Hours are selected via a Stepper supporting 0–16 hours in 0.5-hour
//  increments. Quality is rated with a 1-5 star row in primaryRose.
//

import SwiftUI

// MARK: - SleepLogger

/// A compact sleep tracking component for logging sleep hours and quality.
///
/// Presents a stepper for duration (0–16 hours, 0.5-hour steps) and a
/// five-star quality rater. Both bindings default to `nil` (unlogged state).
///
/// ```swift
/// @State private var sleepHours: Double? = nil
/// @State private var sleepQuality: Int? = nil
///
/// SleepLogger(hours: $sleepHours, quality: $sleepQuality)
/// ```
public struct SleepLogger: View {

    // MARK: Bindings

    @Binding public var hours: Double?
    @Binding public var quality: Int?

    // MARK: State

    @State private var stepperValue: Double

    // MARK: Constants

    private let minHours: Double = 0
    private let maxHours: Double = 16
    private let step: Double = 0.5

    // MARK: Init

    public init(hours: Binding<Double?>, quality: Binding<Int?>) {
        self._hours = hours
        self._quality = quality
        self._stepperValue = State(initialValue: hours.wrappedValue ?? 7.0)
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            // Hours row
            hoursRow

            Divider()
                .background(BloomHerTheme.Colors.textTertiary.opacity(0.3))

            // Quality row
            qualityRow
        }
    }

    // MARK: Hours Row

    private var hoursRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            // Moon icon
            Image(BloomIcons.moonStars)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("Duration")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(formattedHours)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            Spacer()

            // Stepper controls
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                // Decrement
                Button {
                    BloomHerTheme.Haptics.light()
                    adjustHours(by: -step)
                } label: {
                    Image(BloomIcons.minusCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(
                            hours == nil || stepperValue <= minHours
                            ? BloomHerTheme.Colors.textTertiary
                            : BloomHerTheme.Colors.accentLavender
                        )
                }
                .disabled(stepperValue <= minHours)
                .buttonStyle(.plain)

                Text(formattedHoursCompact)
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .monospacedDigit()
                    .frame(minWidth: 44, alignment: .center)

                // Increment
                Button {
                    BloomHerTheme.Haptics.light()
                    adjustHours(by: step)
                } label: {
                    Image(BloomIcons.plusCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(
                            stepperValue >= maxHours
                            ? BloomHerTheme.Colors.textTertiary
                            : BloomHerTheme.Colors.accentLavender
                        )
                }
                .disabled(stepperValue >= maxHours)
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Quality Row

    private var qualityRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            // Star icon
            Image(BloomIcons.starFilled)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("Quality")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(qualityLabel)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            Spacer()

            // Star rating
            HStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
                ForEach(1...5, id: \.self) { star in
                    starButton(for: star)
                }
            }
        }
    }

    @ViewBuilder
    private func starButton(for star: Int) -> some View {
        let isFilled = quality.map { star <= $0 } ?? false

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                quality = (quality == star) ? nil : star
            }
        } label: {
            Image(isFilled ? BloomIcons.starFilled : BloomIcons.star)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(isFilled
                                 ? BloomHerTheme.Colors.primaryRose
                                 : BloomHerTheme.Colors.textTertiary)
                .scaleEffect(isFilled ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(BloomHerTheme.Animation.quick, value: isFilled)
    }

    // MARK: Helpers

    private func adjustHours(by delta: Double) {
        let newValue = max(minHours, min(maxHours, stepperValue + delta))
        withAnimation(BloomHerTheme.Animation.quick) {
            stepperValue = newValue
            hours = newValue
        }
    }

    private var formattedHours: String {
        guard let h = hours else { return "Not logged" }
        let wholeHours = Int(h)
        let hasHalf = h.truncatingRemainder(dividingBy: 1) != 0
        if hasHalf {
            return "\(wholeHours)h 30m"
        } else {
            return "\(wholeHours) hour\(wholeHours == 1 ? "" : "s")"
        }
    }

    private var formattedHoursCompact: String {
        let h = stepperValue
        let wholeHours = Int(h)
        let hasHalf = h.truncatingRemainder(dividingBy: 1) != 0
        return hasHalf ? "\(wholeHours).5" : "\(wholeHours)h"
    }

    private var qualityLabel: String {
        switch quality {
        case 1: return "Poor"
        case 2: return "Below average"
        case 3: return "Average"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Not rated"
        }
    }
}

// MARK: - Preview

#Preview("Sleep Logger") {
    SleepLoggerPreview()
}

private struct SleepLoggerPreview: View {
    @State private var hours: Double? = 7.5
    @State private var quality: Int? = 4

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Text("Sleep")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomCard {
                SleepLogger(hours: $hours, quality: $quality)
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xl)
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .luteal)
    }
}
