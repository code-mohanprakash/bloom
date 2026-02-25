//
//  CrampIntensitySelector.swift
//  BloomHer
//
//  Horizontal 4-level cramp intensity selector using KawaiiFace expressions.
//  Each level uses an appropriately sad/happy face and a phase-appropriate
//  color. The selected item enlarges with a colored background circle and
//  spring animation.
//

import SwiftUI

// MARK: - CrampIntensitySelector

/// A horizontal cramp severity picker that uses kawaii face expressions.
///
/// Four levels are shown — mild, moderate, severe, and debilitating — each
/// with a `KawaiiFace` expression, a colored background circle, and a label.
/// The selected level scales up with a spring animation.
///
/// ```swift
/// @State private var cramps: CrampLevel? = nil
/// CrampIntensitySelector(selected: $cramps)
/// ```
struct CrampIntensitySelector: View {

    // MARK: Binding

    @Binding var selected: CrampLevel?

    // MARK: Init

    init(selected: Binding<CrampLevel?>) {
        self._selected = selected
    }

    // MARK: Body

    var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            ForEach(CrampLevel.allCases, id: \.self) { level in
                crampItem(for: level)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xs)
    }

    // MARK: Cramp Item

    @ViewBuilder
    private func crampItem(for level: CrampLevel) -> some View {
        let isSelected = selected == level
        let baseSize: CGFloat = 52
        let selectedSize: CGFloat = 64

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.standard) {
                selected = (selected == level) ? nil : level
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(circleColor(for: level).opacity(isSelected ? 1.0 : 0.15))
                        .frame(
                            width: isSelected ? selectedSize + 8 : baseSize + 8,
                            height: isSelected ? selectedSize + 8 : baseSize + 8
                        )
                        .animation(BloomHerTheme.Animation.standard, value: isSelected)

                    // Kawaii face
                    KawaiiFace(expression: faceExpression(for: level), size: isSelected ? selectedSize : baseSize)
                        .animation(BloomHerTheme.Animation.standard, value: isSelected)
                }

                Text(level.displayName)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(
                        isSelected
                        ? circleColor(for: level)
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .fontWeight(isSelected ? .semibold : .regular)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: Helpers

    /// Maps a `CrampLevel` to its kawaii face expression.
    private func faceExpression(for level: CrampLevel) -> KawaiiFace.Expression {
        switch level {
        case .mild:         return .happy
        case .moderate:     return .neutral
        case .severe:       return .sad
        case .debilitating: return .sad
        }
    }

    /// Returns the accent color associated with each cramp level.
    ///
    /// - mild: sage (comfortable)
    /// - moderate: peach (caution)
    /// - severe: menstrual rose (pain)
    /// - debilitating: dark red (extreme pain)
    private func circleColor(for level: CrampLevel) -> Color {
        switch level {
        case .mild:         return BloomColors.sageGreen
        case .moderate:     return BloomColors.accentPeach
        case .severe:       return BloomColors.menstrual
        case .debilitating: return Color(hex: "#C0392B")
        }
    }
}

// MARK: - Preview

#Preview("Cramp Intensity Selector") {
    CrampIntensitySelectorPreview()
}

private struct CrampIntensitySelectorPreview: View {
    @State private var selected: CrampLevel? = .moderate

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Text("Cramp Intensity")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Selected: \(selected?.displayName ?? "None")")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    CrampIntensitySelector(selected: $selected)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xl)
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .menstrual)
    }
}
