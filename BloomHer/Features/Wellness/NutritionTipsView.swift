//
//  NutritionTipsView.swift
//  BloomHer
//
//  Phase-specific nutrition guidance screen.
//  Features:
//  • Featured "Tip of the Day" card at the top
//  • Phase filter chips (all phases)
//  • Nutrition tip cards with icon, title, description, food list
//  • Pregnancy trimester mode
//  • Source attribution
//

import SwiftUI

// MARK: - NutritionTipsView

struct NutritionTipsView: View {

    // MARK: State

    let phase: CyclePhase
    @State private var selectedPhaseFilter: CyclePhase?
    @State private var showPregnancyMode: Bool = false
    @State private var selectedTrimester: Int = 1

    @Environment(\.appMode) private var appMode

    // MARK: Computed

    private var filteredTips: [NutritionTip] {
        if showPregnancyMode {
            return NutritionData.tips.filter { $0.isPregnancy && ($0.trimester == nil || $0.trimester == selectedTrimester) }
        }
        if let filter = selectedPhaseFilter {
            return NutritionData.tips.filter { !$0.isPregnancy && ($0.phase == filter || $0.phase == nil) }
        }
        return NutritionData.tips.filter { !$0.isPregnancy }
    }

    private var featuredTip: NutritionTip? {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let pool = NutritionData.tips.filter { $0.phase == phase }
        guard !pool.isEmpty else { return NutritionData.tips.first }
        return pool[dayOfYear % pool.count]
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                // Pregnancy toggle
                if appMode == .pregnant {
                    pregnancyToggle
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }

                // Trimester selector (when pregnancy mode is on)
                if showPregnancyMode {
                    trimesterSelector
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 0)
                } else {
                    // Phase filter chips
                    phaseFilterRow
                        .staggeredAppear(index: 0)
                }

                // Featured tip
                if let tip = featuredTip, !showPregnancyMode {
                    featuredTipCard(tip)
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)
                }

                // Tip cards
                tipsGrid
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Nutrition Tips")
        .onAppear {
            selectedPhaseFilter = phase
        }
        .animation(BloomHerTheme.Animation.standard, value: selectedPhaseFilter)
        .animation(BloomHerTheme.Animation.standard, value: showPregnancyMode)
    }

    // MARK: - Pregnancy Toggle

    private var pregnancyToggle: some View {
        HStack {
            Image(BloomIcons.heartFilled)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
            Text("Pregnancy Mode")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            Spacer()
            Toggle("", isOn: $showPregnancyMode)
                .tint(BloomHerTheme.Colors.primaryRose)
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        )
    }

    // MARK: - Trimester Selector

    private var trimesterSelector: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Trimester")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            BloomSegmentedControl(
                options: ["1st", "2nd", "3rd"],
                selectedIndex: Binding(
                    get: { selectedTrimester - 1 },
                    set: { selectedTrimester = $0 + 1 }
                )
            )
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Phase Filter Chips

    private var phaseFilterRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                // "All" chip
                BloomChip(
                    "All",
                    icon: "square.grid.2x2",
                    color: BloomHerTheme.Colors.textSecondary,
                    isSelected: selectedPhaseFilter == nil,
                    action: { selectedPhaseFilter = nil }
                )

                ForEach(CyclePhase.allCases, id: \.self) { p in
                    BloomChip(
                        p.displayName,
                        icon: p.icon,
                        color: BloomHerTheme.Colors.phase(p),
                        isSelected: selectedPhaseFilter == p,
                        action: { selectedPhaseFilter = p }
                    )
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Featured Tip Card

    private func featuredTipCard(_ tip: NutritionTip) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BloomHerTheme.Colors.phase(phase), BloomHerTheme.Colors.phase(phase).opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.starFilled)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.white)
                    Text("Tip of the Day")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.horizontal, BloomHerTheme.Spacing.sm)
                .padding(.vertical, BloomHerTheme.Spacing.xxs)
                .background(Capsule().fill(.white.opacity(0.2)))

                HStack(alignment: .top, spacing: BloomHerTheme.Spacing.md) {
                    Image(BloomIcons.nutrition)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        Text(tip.title)
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(.white)
                        Text(tip.description)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(3)
                    }
                }

                if let amount = tip.dailyAmount {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.checkmarkSeal)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("Daily: \(amount)")
                            .font(BloomHerTheme.Typography.caption)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(BloomHerTheme.Spacing.lg)
        }
        .frame(height: 200)
        .shadow(color: BloomHerTheme.Colors.phase(phase).opacity(0.3), radius: 16, x: 0, y: 8)
    }

    // MARK: - Tips Grid

    private var tipsGrid: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            if filteredTips.isEmpty {
                emptyTipsState
            } else {
                ForEach(filteredTips) { tip in
                    NutritionTipCard(tip: tip)
                }
            }
        }
    }

    private var emptyTipsState: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            KawaiiFace(expression: .neutral, size: 64)
            Text("No tips for this filter")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BloomHerTheme.Spacing.xxl)
    }
}

// MARK: - NutritionTipCard

private struct NutritionTipCard: View {
    let tip: NutritionTip
    @State private var isExpanded: Bool = false

    var body: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                // Header row
                HStack(alignment: .top, spacing: BloomHerTheme.Spacing.md) {
                    // Icon circle
                    ZStack {
                        Circle()
                            .fill(phaseColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(BloomIcons.nutrition)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        HStack(spacing: BloomHerTheme.Spacing.xs) {
                            Text(tip.title)
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            Spacer()
                            if let phase = tip.phase {
                                Text(phase.displayName)
                                    .font(BloomHerTheme.Typography.caption2)
                                    .foregroundStyle(BloomHerTheme.Colors.phase(phase))
                                    .padding(.horizontal, BloomHerTheme.Spacing.xxs + 2)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule().fill(BloomHerTheme.Colors.phase(phase).opacity(0.12))
                                    )
                            }
                        }

                        Text(tip.nutrient)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(phaseColor)
                    }
                }

                Text(tip.description)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .lineLimit(isExpanded ? nil : 2)

                // Food list (shown when expanded)
                if isExpanded {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        Text("Recommended Foods")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            alignment: .leading,
                            spacing: BloomHerTheme.Spacing.xs
                        ) {
                            ForEach(tip.foods, id: \.self) { food in
                                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                                    Circle()
                                        .fill(phaseColor)
                                        .frame(width: 5, height: 5)
                                    Text(food)
                                        .font(BloomHerTheme.Typography.footnote)
                                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Footer row
                HStack {
                    if let amount = tip.dailyAmount {
                        HStack(spacing: BloomHerTheme.Spacing.xxs) {
                            Image(BloomIcons.target)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            Text(amount)
                                .font(BloomHerTheme.Typography.caption)
                        }
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }

                    Spacer()

                    Text("Source: \(tip.source)")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .italic()

                    Button {
                        withAnimation(BloomHerTheme.Animation.standard) {
                            isExpanded.toggle()
                        }
                        BloomHerTheme.Haptics.light()
                    } label: {
                        Image(isExpanded ? BloomIcons.chevronUp : BloomIcons.chevronDown)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var phaseColor: Color {
        tip.phase.map { BloomHerTheme.Colors.phase($0) } ?? BloomHerTheme.Colors.sageGreen
    }
}

// MARK: - Preview

#Preview("Nutrition Tips") {
    NavigationStack {
        NutritionTipsView(phase: .menstrual)
    }
    .environment(\.currentCyclePhase, .menstrual)
}

#Preview("Nutrition Tips — Follicular") {
    NavigationStack {
        NutritionTipsView(phase: .follicular)
    }
    .environment(\.currentCyclePhase, .follicular)
}
