//
//  BloomChip.swift
//  BloomHer
//
//  A pill-shaped toggle chip with spring animation and haptic feedback.
//  Selected state fills with the chip color and shows white text;
//  unselected state shows a colored border with colored text.
//

import SwiftUI

// MARK: - BloomChip

/// A compact, toggleable pill chip for filters, tags, and multi-select options.
///
/// ```swift
/// @State private var isSelected = false
///
/// BloomChip("Cramps", icon: "bolt.fill", isSelected: isSelected) {
///     isSelected.toggle()
/// }
///
/// // Custom color:
/// BloomChip("Ovulation", color: BloomHerTheme.Colors.accentPeach, isSelected: isSelected) {
///     isSelected.toggle()
/// }
/// ```
public struct BloomChip: View {

    // MARK: Configuration

    private let label: String
    private let icon: String?
    private let color: Color
    private let isSelected: Bool
    private let action: () -> Void

    // MARK: Init

    /// Creates a `BloomChip`.
    ///
    /// - Parameters:
    ///   - label: The chip's text content.
    ///   - icon: Optional SF Symbol name displayed before the label.
    ///   - color: Fill/border/text color. Defaults to `primaryRose`.
    ///   - isSelected: Whether the chip is in its selected (filled) state.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        _ label: String,
        icon: String? = nil,
        color: Color = BloomHerTheme.Colors.primaryRose,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: Body

    public var body: some View {
        Button {
            BloomHerTheme.Haptics.selection()
            action()
        } label: {
            chipLabel
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: Label

    private var chipLabel: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            if let icon {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 14, height: 14)
            }
            Text(label)
                .font(BloomHerTheme.Typography.subheadline)
        }
        .foregroundStyle(isSelected ? .white : color)
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xxs + 2)
        .background(chipBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(color, lineWidth: isSelected ? 0 : 1.5)
        )
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            color
        } else {
            Color.clear
        }
    }
}

// MARK: - Preview

#Preview("Bloom Chip") {
    ChipPreviewContainer()
}

private struct ChipPreviewContainer: View {
    @State private var selectedSymptoms: Set<String> = []

    private let symptoms = ["Cramps", "Headache", "Bloating", "Mood Swings", "Fatigue", "Acne"]
    private let colors: [Color] = [
        BloomHerTheme.Colors.primaryRose,
        BloomHerTheme.Colors.sageGreen,
        BloomHerTheme.Colors.accentLavender,
        BloomHerTheme.Colors.accentPeach,
        BloomHerTheme.Colors.primaryRose,
        BloomHerTheme.Colors.sageGreen
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.lg) {
            Text("Select Symptoms")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            FlowLayout(spacing: BloomHerTheme.Spacing.sm) {
                ForEach(Array(zip(symptoms, colors)), id: \.0) { symptom, color in
                    BloomChip(
                        symptom,
                        color: color,
                        isSelected: selectedSymptoms.contains(symptom)
                    ) {
                        if selectedSymptoms.contains(symptom) {
                            selectedSymptoms.remove(symptom)
                        } else {
                            selectedSymptoms.insert(symptom)
                        }
                    }
                }
            }

            // With icons
            Text("With Icons")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                BloomChip("Drop", icon: BloomIcons.drop, color: BloomHerTheme.Colors.primaryRose, isSelected: true) { }
                BloomChip("Leaf", icon: BloomIcons.leaf, color: BloomHerTheme.Colors.sageGreen, isSelected: false) { }
                BloomChip("Moon", icon: BloomIcons.moonStars, color: BloomHerTheme.Colors.accentLavender, isSelected: true) { }
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.background)
    }
}

// MARK: - FlowLayout (private helper for preview)

/// A simple wrapping flow layout used only in the preview.
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > containerWidth && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        return CGSize(width: containerWidth, height: y + maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}
