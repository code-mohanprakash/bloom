//
//  BloomFruitBaby.swift
//  BloomHer
//
//  Pregnancy week fruit illustration selector.
//  Maps gestational weeks (4-40) to kawaii fruit illustrations with
//  a size label and cute caption below.
//

import SwiftUI

// MARK: - BloomFruitBaby

struct BloomFruitBaby: View {

    /// Current gestational week (1-42).
    let week: Int
    /// Bounding size for the fruit illustration.
    let size: CGFloat

    // MARK: - Week-to-fruit mapping

    /// Returns the closest matching fruit milestone for the given week.
    private var fruitEntry: FruitMilestone {
        let milestones = FruitMilestone.allMilestones
        // Find exact match first
        if let exact = milestones.first(where: { $0.week == week }) {
            return exact
        }
        // Interpolate — find the nearest milestone
        let sorted = milestones.sorted { abs($0.week - week) < abs($1.week - week) }
        return sorted[0]
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            // Fruit illustration
            fruitView
                .phaseAnimator([false, true]) { view, bounced in
                    view.offset(y: bounced ? -6 : 0)
                } animation: { _ in
                    .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                }
                .frame(width: size, height: size)

            // Caption
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Text("Your baby is the size of a")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                Text(fruitEntry.name)
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(fruitEntry.sizeLabel)
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Week \(week): baby is the size of a \(fruitEntry.name), \(fruitEntry.sizeLabel)")
    }

    // MARK: - Fruit view router

    @ViewBuilder
    private var fruitView: some View {
        switch fruitEntry.illustration {
        case .poppySeed:    PoppySeedShape(size: size)
        case .raspberry:    RaspberryShape(size: size)
        case .lime:         LimeShape(size: size)
        case .avocado:      AvocadoShape(size: size)
        case .banana:       BananaShape(size: size)
        case .corn:         CornShape(size: size)
        case .eggplant:     EggplantShape(size: size)
        case .coconut:      CoconutShape(size: size)
        case .melon:        MelonShape(size: size)
        case .watermelon:   WatermelonShape(size: size)
        default:
            // Fallback — should not occur with proper milestone data
            Circle()
                .fill(BloomColors.primaryRose.opacity(0.4))
                .frame(width: size * 0.6, height: size * 0.6)
                .overlay(KawaiiFace(expression: .neutral, size: size * 0.3))
        }
    }
}

// MARK: - FruitMilestone

/// Metadata for a single fruit milestone in the pregnancy journey.
private struct FruitMilestone {
    let week: Int
    let name: String
    let sizeLabel: String
    let illustration: KawaiiIllustration

    static let allMilestones: [FruitMilestone] = [
        FruitMilestone(week: 4,  name: "Poppy Seed",  sizeLabel: "~1 mm",   illustration: .poppySeed),
        FruitMilestone(week: 8,  name: "Raspberry",   sizeLabel: "~1.6 cm", illustration: .raspberry),
        FruitMilestone(week: 12, name: "Lime",        sizeLabel: "~5.4 cm", illustration: .lime),
        FruitMilestone(week: 16, name: "Avocado",     sizeLabel: "~11.6 cm",illustration: .avocado),
        FruitMilestone(week: 20, name: "Banana",      sizeLabel: "~25.6 cm",illustration: .banana),
        FruitMilestone(week: 24, name: "Corn",        sizeLabel: "~30 cm",  illustration: .corn),
        FruitMilestone(week: 28, name: "Eggplant",    sizeLabel: "~37.6 cm",illustration: .eggplant),
        FruitMilestone(week: 32, name: "Coconut",     sizeLabel: "~42.4 cm",illustration: .coconut),
        FruitMilestone(week: 36, name: "Honeydew Melon", sizeLabel: "~47.4 cm", illustration: .melon),
        FruitMilestone(week: 40, name: "Watermelon",  sizeLabel: "~51.2 cm",illustration: .watermelon),
    ]
}

// MARK: - Week navigation strip

/// A horizontal week-picker strip used below BloomFruitBaby in context.
struct FruitBabyWeekStrip: View {
    @Binding var selectedWeek: Int
    let weeks = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                ForEach(weeks, id: \.self) { w in
                    Button {
                        withAnimation(BloomHerTheme.Animation.standard) {
                            selectedWeek = w
                        }
                        BloomHerTheme.Haptics.selection()
                    } label: {
                        Text("Wk \(w)")
                            .font(BloomHerTheme.Typography.caption)
                            .padding(.horizontal, BloomHerTheme.Spacing.sm)
                            .padding(.vertical, BloomHerTheme.Spacing.xxs)
                            .background(
                                Capsule().fill(
                                    selectedWeek == w
                                    ? BloomColors.primaryRose
                                    : BloomColors.primaryRose.opacity(0.12)))
                            .foregroundStyle(
                                selectedWeek == w ? .white : BloomColors.primaryRose)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview("Fruit Baby") {
    struct PreviewWrapper: View {
        @State private var selectedWeek = 20
        var body: some View {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                Text("Week \(selectedWeek)")
                    .font(BloomHerTheme.Typography.title2)

                BloomFruitBaby(week: selectedWeek, size: 160)

                FruitBabyWeekStrip(selectedWeek: $selectedWeek)
            }
            .padding()
            .background(Color(hex: "#FFF8F5"))
        }
    }
    return PreviewWrapper()
}
