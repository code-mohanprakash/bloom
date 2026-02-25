//
//  FlowSelector.swift
//  BloomHer
//
//  Horizontal row of selectable flow intensity items including a "None" option.
//  Each item shows a drop icon scaled by intensity, a dot-count indicator, and
//  a label. Selected state fills with the menstrual phase color; unselected
//  shows a colored outline.
//

import SwiftUI

// MARK: - FlowSelector

/// A horizontal selector for menstrual flow intensity.
///
/// Presents six options — "None" followed by all `FlowLevel` cases — in a
/// scrollable row. Selecting a level provides haptic feedback and animates
/// the fill/outline state.
///
/// ```swift
/// @State private var flow: FlowLevel? = nil
/// FlowSelector(selected: $flow)
/// ```
struct FlowSelector: View {

    // MARK: Binding

    @Binding var selected: FlowLevel?

    // MARK: Init

    init(selected: Binding<FlowLevel?>) {
        self._selected = selected
    }

    // MARK: Body

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                // "None" clear option
                noneItem

                ForEach(FlowLevel.allCases, id: \.self) { level in
                    flowItem(for: level)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.xxs)
        }
    }

    // MARK: None Item

    private var noneItem: some View {
        let isSelected = selected == nil
        return Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selected = nil
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? BloomColors.menstrual
                              : Color.clear)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.clear : BloomColors.menstrual,
                                    lineWidth: 1.5
                                )
                        )
                    Image(BloomIcons.xmark)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(isSelected ? .white : BloomColors.menstrual)
                }

                Text("None")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(
                        isSelected
                        ? BloomColors.menstrual
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: Flow Item

    @ViewBuilder
    private func flowItem(for level: FlowLevel) -> some View {
        let isSelected = selected == level

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selected = level
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? BloomColors.menstrual
                              : Color.clear)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.clear : BloomColors.menstrual,
                                    lineWidth: 1.5
                                )
                        )

                    VStack(spacing: 2) {
                        Image(level.icon)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: dropIconSize(for: level), height: dropIconSize(for: level))
                            .foregroundStyle(isSelected ? .white : BloomColors.menstrual)

                        // Dot count indicator
                        HStack(spacing: 2) {
                            ForEach(0..<level.dotCount, id: \.self) { _ in
                                Circle()
                                    .fill(isSelected ? Color.white.opacity(0.85) : BloomColors.menstrual)
                                    .frame(width: 3, height: 3)
                            }
                        }
                    }
                }

                Text(level.displayName)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(
                        isSelected
                        ? BloomColors.menstrual
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 58)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: Helpers

    private func dropIconSize(for level: FlowLevel) -> CGFloat {
        switch level {
        case .spotting:  return 10
        case .light:     return 13
        case .medium:    return 15
        case .heavy:     return 17
        case .veryHeavy: return 19
        }
    }
}

// MARK: - Preview

#Preview("Flow Selector") {
    FlowSelectorPreview()
}

private struct FlowSelectorPreview: View {
    @State private var selected: FlowLevel? = .medium

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Text("Flow Intensity")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Selected: \(selected?.displayName ?? "None")")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    FlowSelector(selected: $selected)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xl)
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .menstrual)
    }
}
