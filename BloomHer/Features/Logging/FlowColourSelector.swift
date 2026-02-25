//
//  FlowColourSelector.swift
//  BloomHer
//
//  A horizontal row of color-dot selectors for menstrual flow colour.
//  Each dot is filled with the `FlowColour`'s canonical color. The selected
//  dot scales up and gains a contrasting ring border to indicate selection.
//

import SwiftUI

// MARK: - FlowColourSelector

/// A horizontal colour-dot picker for logging menstrual flow colour.
///
/// Each option displays a filled circle in the actual observed colour with a
/// label beneath. Selecting a colour scales the dot up with a spring animation
/// and provides haptic feedback.
///
/// ```swift
/// @State private var colour: FlowColour? = nil
/// FlowColourSelector(selected: $colour)
/// ```
struct FlowColourSelector: View {

    // MARK: Binding

    @Binding var selected: FlowColour?

    // MARK: Constants

    private let dotSize: CGFloat = 36
    private let selectedDotSize: CGFloat = 46

    // MARK: Init

    init(selected: Binding<FlowColour?>) {
        self._selected = selected
    }

    // MARK: Body

    var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.lg) {
            ForEach(FlowColour.allCases, id: \.self) { colour in
                colourDot(for: colour)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .padding(.vertical, BloomHerTheme.Spacing.xs)
    }

    // MARK: Colour Dot

    @ViewBuilder
    private func colourDot(for colour: FlowColour) -> some View {
        let isSelected = selected == colour
        let size: CGFloat = isSelected ? selectedDotSize : dotSize

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selected = (selected == colour) ? nil : colour
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
                ZStack {
                    // Outer ring when selected
                    if isSelected {
                        Circle()
                            .strokeBorder(ringColor(for: colour), lineWidth: 2.5)
                            .frame(width: size + 6, height: size + 6)
                    }

                    Circle()
                        .fill(colour.color)
                        .frame(width: size, height: size)
                        .shadow(
                            color: colour.color.opacity(isSelected ? 0.45 : 0.20),
                            radius: isSelected ? 8 : 3,
                            x: 0, y: 2
                        )

                    // Checkmark on selected
                    if isSelected {
                        Image(BloomIcons.checkmark)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 13, height: 13)
                            .foregroundStyle(checkmarkColor(for: colour))
                    }
                }
                .frame(width: selectedDotSize + 6, height: selectedDotSize + 6)
                .animation(BloomHerTheme.Animation.quick, value: isSelected)

                Text(colour.displayName)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(
                        isSelected
                        ? BloomHerTheme.Colors.textPrimary
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .fontWeight(isSelected ? .semibold : .regular)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: Helpers

    /// Returns a ring color that contrasts well with the dot's fill.
    private func ringColor(for colour: FlowColour) -> Color {
        switch colour {
        case .black:
            return BloomColors.primaryRose
        default:
            return colour.color.opacity(0.75)
        }
    }

    /// Returns a checkmark color that reads over the dot fill.
    private func checkmarkColor(for colour: FlowColour) -> Color {
        switch colour {
        case .pink:
            return Color(hex: "#8B4513")
        case .red, .darkRed, .brown, .black:
            return .white
        }
    }
}

// MARK: - Preview

#Preview("Flow Colour Selector") {
    FlowColourSelectorPreview()
}

private struct FlowColourSelectorPreview: View {
    @State private var selected: FlowColour? = .red

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Text("Flow Colour")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Selected: \(selected?.displayName ?? "None")")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    FlowColourSelector(selected: $selected)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xl)
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .menstrual)
    }
}
