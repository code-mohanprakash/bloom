//
//  CategoryCard.swift
//  BloomHer
//
//  Reusable grid card for an exercise category. Displays an icon in a
//  tinted circle, the category name, routine count, and an optional
//  pregnancy-safety indicator dot.
//

import SwiftUI

// MARK: - CategoryCard

/// A tappable card representing a single `ExerciseCategory` in the browse grid.
///
/// The icon ring is tinted with the category's canonical color. When the user
/// is pregnant and the category has known pregnancy relevance, a coloured
/// safety dot appears in the top-trailing corner.
struct CategoryCard: View {

    // MARK: - Configuration

    let category: ExerciseCategory
    let routineCount: Int
    let isPregnant: Bool
    let trimester: Int?

    // MARK: - Body

    var body: some View {
        BloomCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {

                HStack(alignment: .top) {
                    iconCircle
                    Spacer()
                    if isPregnant {
                        pregnancySafetyDot
                    }
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(category.displayName)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    routineCountBadge
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Icon Circle

    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.15))
                .frame(width: 48, height: 48)

            Image(BloomIcons.yoga)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }

    // MARK: - Routine Count Badge

    private var routineCountBadge: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Image(BloomIcons.listBullet)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text("\(routineCount) routine\(routineCount == 1 ? "" : "s")")
                .font(BloomHerTheme.Typography.caption)
        }
        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
    }

    // MARK: - Pregnancy Safety Dot

    @ViewBuilder
    private var pregnancySafetyDot: some View {
        let safetyColor = pregnancySafetyColor
        Circle()
            .fill(safetyColor)
            .frame(width: 10, height: 10)
            .bloomShadow(BloomHerTheme.Shadows.small)
            .accessibilityLabel(pregnancySafetyAccessibilityLabel)
    }

    // MARK: - Helpers

    /// The primary display color for this category.
    private var categoryColor: Color {
        switch category {
        case .menstrualYoga:     return BloomHerTheme.Colors.primaryRose
        case .follicularEnergy:  return BloomHerTheme.Colors.sageGreen
        case .ovulationPower:    return BloomHerTheme.Colors.accentPeach
        case .lutealWindDown:    return BloomHerTheme.Colors.accentLavender
        case .prenatalT1:        return BloomColors.follicular
        case .prenatalT2:        return BloomColors.follicular
        case .prenatalT3:        return BloomColors.ovulation
        case .postpartumRecovery: return BloomColors.luteal
        case .labourPrep:        return BloomHerTheme.Colors.accentPeach
        case .pelvicFloor:       return BloomHerTheme.Colors.accentLavender
        case .breathing:         return BloomColors.luteal
        }
    }

    /// The safety dot color given the user's current trimester.
    private var pregnancySafetyColor: Color {
        guard isPregnant else { return .clear }
        if category.isPrenatal || category == .pelvicFloor || category == .breathing {
            return BloomHerTheme.Colors.success
        }
        if category == .postpartumRecovery { return BloomHerTheme.Colors.warning }
        return BloomHerTheme.Colors.error
    }

    private var pregnancySafetyAccessibilityLabel: String {
        guard isPregnant else { return "" }
        if category.isPrenatal || category == .pelvicFloor || category == .breathing {
            return "Pregnancy safe"
        }
        if category == .postpartumRecovery { return "Check with provider" }
        return "Not recommended during pregnancy"
    }
}

// MARK: - Preview

#Preview("Category Card Grid") {
    let columns = [
        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm),
        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm)
    ]
    return ScrollView {
        LazyVGrid(columns: columns, spacing: BloomHerTheme.Spacing.sm) {
            ForEach(ExerciseCategory.allCases.prefix(8), id: \.self) { category in
                CategoryCard(
                    category: category,
                    routineCount: Int.random(in: 1...6),
                    isPregnant: true,
                    trimester: 2
                )
            }
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
}
