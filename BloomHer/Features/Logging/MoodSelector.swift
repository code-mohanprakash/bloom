//
//  MoodSelector.swift
//  BloomHer
//
//  A wrapping flow-layout grid of mood chips for multi-select logging.
//  Uses a custom FlowLayout so chips wrap naturally across varying widths.
//  Selected chips fill with accent lavender; unselected show a lavender outline.
//

import SwiftUI

// MARK: - MoodSelector

/// A multi-select mood picker presented in a wrapping chip grid.
///
/// Each mood displays its emoji and display name in a `BloomChip`-styled pill.
/// Multiple moods can be selected simultaneously. Tapping a selected mood
/// deselects it.
///
/// ```swift
/// @State private var moods: Set<Mood> = []
/// MoodSelector(selected: $moods)
/// ```
struct MoodSelector: View {

    // MARK: Binding

    @Binding var selected: Set<Mood>

    // MARK: Init

    init(selected: Binding<Set<Mood>>) {
        self._selected = selected
    }

    // MARK: Body

    var body: some View {
        MoodFlowLayout(spacing: BloomHerTheme.Spacing.xs) {
            ForEach(Mood.allCases, id: \.self) { mood in
                moodChip(for: mood)
            }
        }
    }

    // MARK: Mood Chip

    @ViewBuilder
    private func moodChip(for mood: Mood) -> some View {
        let isSelected = selected.contains(mood)

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                if isSelected {
                    selected.remove(mood)
                } else {
                    selected.insert(mood)
                }
            }
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
                Text(mood.emoji)
                    .font(BloomHerTheme.Typography.subheadline)

                Text(mood.displayName)
                    .font(BloomHerTheme.Typography.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(isSelected ? .white : BloomHerTheme.Colors.accentLavender)
            .padding(.horizontal, BloomHerTheme.Spacing.sm)
            .padding(.vertical, BloomHerTheme.Spacing.xxs + 2)
            .background(
                Group {
                    if isSelected {
                        BloomHerTheme.Colors.accentLavender
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        BloomHerTheme.Colors.accentLavender,
                        lineWidth: isSelected ? 0 : 1.5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }
}

// MARK: - MoodFlowLayout

/// A wrapping flow layout for the mood chips.
///
/// Chips are placed left-to-right and wrap to the next row when they exceed
/// the available container width.
private struct MoodFlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? UIScreen.main.bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > containerWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: containerWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Preview

#Preview("Mood Selector") {
    MoodSelectorPreview()
}

private struct MoodSelectorPreview: View {
    @State private var selected: Set<Mood> = [.happy, .energetic]

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                Text("How are you feeling?")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                BloomCard {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                        Text("\(selected.count) mood\(selected.count == 1 ? "" : "s") selected")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                        MoodSelector(selected: $selected)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.vertical, BloomHerTheme.Spacing.xl)
        }
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .follicular)
    }
}
