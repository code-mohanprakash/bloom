//
//  BloomSegmentedControl.swift
//  BloomHer
//
//  A fully custom segmented control with a spring-animated sliding capsule
//  indicator, matched geometry effect, and haptic feedback on segment change.
//

import SwiftUI

// MARK: - BloomSegmentedControl

/// A custom segmented control styled with BloomHer design tokens.
///
/// Unlike the system `Picker(.segmented)`, this component uses a
/// `matchedGeometryEffect` to animate a rose-filled capsule sliding between
/// segments. Unselected segments show secondary text on a transparent background.
///
/// ```swift
/// @State private var selected = 0
///
/// BloomSegmentedControl(
///     options: ["Day", "Week", "Month", "Year"],
///     selectedIndex: $selected
/// )
/// ```
public struct BloomSegmentedControl: View {

    // MARK: Configuration

    private let options: [String]
    @Binding private var selectedIndex: Int

    // MARK: Namespace

    @Namespace private var indicatorNamespace

    // MARK: Init

    /// Creates a `BloomSegmentedControl`.
    ///
    /// - Parameters:
    ///   - options: The string labels for each segment, in display order.
    ///   - selectedIndex: A binding to the index of the currently selected segment.
    public init(options: [String], selectedIndex: Binding<Int>) {
        self.options = options
        self._selectedIndex = selectedIndex
    }

    // MARK: Body

    public var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            ForEach(options.indices, id: \.self) { index in
                segmentButton(for: index)
            }
        }
        .padding(BloomHerTheme.Spacing.xxs)
        .background(
            Capsule(style: .continuous)
                .fill(BloomHerTheme.Colors.background)
        )
    }

    // MARK: Segment Button

    private func segmentButton(for index: Int) -> some View {
        let isSelected = index == selectedIndex

        return Button {
            guard index != selectedIndex else { return }
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selectedIndex = index
            }
        } label: {
            Text(options[index])
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(isSelected ? .white : BloomHerTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BloomHerTheme.Spacing.xs)
                .background {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(BloomHerTheme.Colors.primaryRose)
                            .matchedGeometryEffect(id: "indicator", in: indicatorNamespace)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(BloomHerTheme.Animation.quick, value: selectedIndex)
    }
}

// MARK: - Preview

#Preview("Bloom Segmented Control") {
    SegmentedControlPreviewContainer()
}

private struct SegmentedControlPreviewContainer: View {
    @State private var selectedIndex = 0
    @State private var periodIndex = 1

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xxl) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Time Range").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                BloomSegmentedControl(options: ["Day", "Week", "Month"], selectedIndex: $selectedIndex)
                Text("Selected: \(["Day", "Week", "Month"][selectedIndex])").font(BloomHerTheme.Typography.footnote).foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Cycle Period").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                BloomSegmentedControl(options: ["1M", "3M", "6M", "1Y"], selectedIndex: $periodIndex)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.surface, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large))
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
    }
}
