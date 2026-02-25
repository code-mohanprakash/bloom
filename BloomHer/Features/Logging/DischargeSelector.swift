//
//  DischargeSelector.swift
//  BloomHer
//
//  A single-select horizontal scrolling chip row for cervical discharge type.
//  Each `DischargeType` case is shown as a `BloomChip`. The selected option
//  fills with primaryRose; all others show an outline.
//

import SwiftUI

// MARK: - DischargeSelector

/// A horizontally scrollable single-select picker for cervical discharge type.
///
/// Presents all `DischargeType` cases as chips. Tapping the currently
/// selected option deselects it (returns to `nil`).
///
/// ```swift
/// @State private var discharge: DischargeType? = nil
/// DischargeSelector(selected: $discharge)
/// ```
struct DischargeSelector: View {

    // MARK: Binding

    @Binding var selected: DischargeType?

    // MARK: Init

    init(selected: Binding<DischargeType?>) {
        self._selected = selected
    }

    // MARK: Body

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                ForEach(DischargeType.allCases, id: \.self) { type in
                    dischargeChip(for: type)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.vertical, BloomHerTheme.Spacing.xxs)
        }
    }

    // MARK: Discharge Chip

    @ViewBuilder
    private func dischargeChip(for type: DischargeType) -> some View {
        let isSelected = selected == type

        BloomChip(
            type.displayName,
            icon: type.icon,
            color: BloomHerTheme.Colors.primaryRose,
            isSelected: isSelected
        ) {
            withAnimation(BloomHerTheme.Animation.quick) {
                selected = (selected == type) ? nil : type
            }
        }
    }
}

// MARK: - Preview

#Preview("Discharge Selector") {
    DischargeSelectorPreview()
}

private struct DischargeSelectorPreview: View {
    @State private var selected: DischargeType? = .creamy

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Text("Discharge")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Selected: \(selected?.displayName ?? "None")")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    DischargeSelector(selected: $selected)
                        .padding(.horizontal, -BloomHerTheme.Spacing.md)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xl)
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .follicular)
    }
}
