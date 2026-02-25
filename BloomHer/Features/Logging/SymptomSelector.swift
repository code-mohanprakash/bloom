//
//  SymptomSelector.swift
//  BloomHer
//
//  A scrollable multi-select symptom picker arranged in a 2-column lazy grid.
//  Each symptom shows its SF Symbol icon and display name in a chip.
//  Selected chips fill with primaryRose; unselected show a rose outline.
//

import SwiftUI

// MARK: - SymptomSelector

/// A two-column scrollable grid of symptom chips for multi-select logging.
///
/// Each chip displays a symptom's SF Symbol icon and display name. Multiple
/// symptoms can be selected simultaneously. Tapping a selected symptom
/// removes it from the selection.
///
/// ```swift
/// @State private var symptoms: Set<Symptom> = []
/// SymptomSelector(selected: $symptoms)
/// ```
struct SymptomSelector: View {

    // MARK: Binding

    @Binding var selected: Set<Symptom>

    // MARK: Grid Configuration

    private let columns = [
        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xs),
        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xs)
    ]

    // MARK: Init

    init(selected: Binding<Set<Symptom>>) {
        self._selected = selected
    }

    // MARK: Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: BloomHerTheme.Spacing.xs) {
            ForEach(Symptom.allCases, id: \.self) { symptom in
                symptomChip(for: symptom)
            }
        }
    }

    // MARK: Symptom Chip

    @ViewBuilder
    private func symptomChip(for symptom: Symptom) -> some View {
        let isSelected = selected.contains(symptom)

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                if isSelected {
                    selected.remove(symptom)
                } else {
                    selected.insert(symptom)
                }
            }
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
                Image(symptom.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 13, height: 13)

                Text(symptom.displayName)
                    .font(BloomHerTheme.Typography.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? .white : BloomHerTheme.Colors.primaryRose)
            .padding(.horizontal, BloomHerTheme.Spacing.sm)
            .padding(.vertical, BloomHerTheme.Spacing.xs)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .fill(isSelected
                          ? BloomHerTheme.Colors.primaryRose
                          : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .strokeBorder(
                        BloomHerTheme.Colors.primaryRose,
                        lineWidth: isSelected ? 0 : 1.5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }
}

// MARK: - Preview

#Preview("Symptom Selector") {
    SymptomSelectorPreview()
}

private struct SymptomSelectorPreview: View {
    @State private var selected: Set<Symptom> = [.headache, .bloating]

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                Text("Symptoms")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                BloomCard {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                        Text("\(selected.count) symptom\(selected.count == 1 ? "" : "s") selected")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                        SymptomSelector(selected: $selected)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.vertical, BloomHerTheme.Spacing.xl)
        }
        .background(BloomHerTheme.Colors.background)
        .environment(\.currentCyclePhase, .menstrual)
    }
}
