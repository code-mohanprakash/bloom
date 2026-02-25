//
//  EnergyLevelSelector.swift
//  BloomHer
//
//  A 1-5 horizontal energy level selector with colour-coded filled segments.
//  Each level fills all segments up to and including the tapped level,
//  creating a "battery bar" effect. Color ramps from red (1) through to
//  bright green (5).
//

import SwiftUI

// MARK: - EnergyLevelSelector

/// A 1-5 horizontal energy level picker with a gradient colour ramp.
///
/// Selecting a level fills all circles up to that level. The edge labels
/// "Exhausted" and "Energetic" anchor the scale. Tapping the active level
/// deselects (sets to `nil`).
///
/// ```swift
/// @State private var energy: Int? = nil
/// EnergyLevelSelector(value: $energy)
/// ```
public struct EnergyLevelSelector: View {

    // MARK: Binding

    @Binding public var value: Int?

    // MARK: Constants

    private let totalLevels = 5
    private let circleSize: CGFloat = 44

    // MARK: Init

    public init(value: Binding<Int?>) {
        self._value = value
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            // Level circles
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                ForEach(1...totalLevels, id: \.self) { level in
                    energyCircle(for: level)
                }
            }
            .frame(maxWidth: .infinity)

            // Edge labels
            HStack {
                Text("Exhausted")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)

                Spacer()

                Text("Energetic")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .padding(.horizontal, BloomHerTheme.Spacing.xxs)
        }
    }

    // MARK: Energy Circle

    @ViewBuilder
    private func energyCircle(for level: Int) -> some View {
        let isFilled = value.map { level <= $0 } ?? false
        let isExactLevel = value == level
        let levelColor = color(for: level)

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                if value == level {
                    // Tapping the current level deselects
                    value = nil
                } else {
                    value = level
                }
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                ZStack {
                    Circle()
                        .fill(isFilled ? levelColor : Color.clear)
                        .frame(width: circleSize, height: circleSize)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isFilled ? levelColor : levelColor.opacity(0.35),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: isFilled ? levelColor.opacity(0.35) : .clear,
                            radius: 6, x: 0, y: 2
                        )

                    // Level number label
                    Text("\(level)")
                        .font(BloomHerTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            isFilled
                            ? .white
                            : levelColor.opacity(0.6)
                        )
                }
                .scaleEffect(isExactLevel ? 1.12 : 1.0)
                .animation(BloomHerTheme.Animation.quick, value: isExactLevel)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(BloomHerTheme.Animation.quick, value: isFilled)
    }

    // MARK: Color Ramp

    /// Returns the color for each energy level on a red→orange→yellow→sage→green ramp.
    private func color(for level: Int) -> Color {
        switch level {
        case 1: return Color(hex: "#E74C3C")        // red — exhausted
        case 2: return Color(hex: "#E67E22")        // orange — low
        case 3: return Color(hex: "#F1C40F")        // yellow — okay
        case 4: return BloomColors.sageGreen        // sage — good
        case 5: return Color(hex: "#27AE60")        // green — energetic
        default: return BloomColors.sageGreen
        }
    }
}

// MARK: - Preview

#Preview("Energy Level Selector") {
    EnergyLevelSelectorPreview()
}

private struct EnergyLevelSelectorPreview: View {
    @State private var value: Int? = 3

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Text("Energy Level")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text(value.map { "Level \($0)" } ?? "Not set")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    EnergyLevelSelector(value: $value)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xl)
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .follicular)
    }
}
