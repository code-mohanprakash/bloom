//
//  ModeSelectionPageView.swift
//  BloomHer
//
//  Page 1 — user picks their primary tracking mode.
//
//  Three large tappable cards, one per AppMode.  Each card has:
//    • A left accent bar in the mode's brand color
//    • SF Symbol icon in the mode's color
//    • Title (headline) + description (subheadline, textSecondary)
//    • Selected state: tinted background fill + trailing checkmark
//    • Spring scale tap animation + haptic selection feedback
//

import SwiftUI

// MARK: - ModeSelectionPageView

struct ModeSelectionPageView: View {

    // MARK: Input

    @Bindable var viewModel: OnboardingViewModel

    // MARK: Entrance animation

    @State private var headerVisible: Bool = false
    @State private var cardsVisible: [Bool] = [false, false, false]

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xxl) {
                Spacer(minLength: BloomHerTheme.Spacing.massive)

                // ── Header ─────────────────────────────────────────────────
                headerSection

                // ── Mode cards ─────────────────────────────────────────────
                VStack(spacing: BloomHerTheme.Spacing.md) {
                    ForEach(Array(ModeOption.allCases.enumerated()), id: \.element.id) { index, option in
                        ModeCard(
                            option: option,
                            isSelected: viewModel.selectedMode == option.mode
                        ) {
                            selectMode(option.mode)
                        }
                        .opacity(cardsVisible[index] ? 1 : 0)
                        .offset(y: cardsVisible[index] ? 0 : 24)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)

                // ── Advance button ─────────────────────────────────────────
                BloomButton(
                    "Continue",
                    style: .primary,
                    size: .large,
                    icon: BloomIcons.chevronRight,
                    isFullWidth: true
                ) {
                    viewModel.advance()
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
                .opacity(headerVisible ? 1 : 0)

                Spacer(minLength: BloomHerTheme.Spacing.massive + BloomHerTheme.Spacing.xl)
            }
        }
        .onAppear(perform: runEntranceAnimation)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            Text("What brings you here?")
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("You can always change this later in Settings.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.xl)
        .opacity(headerVisible ? 1 : 0)
        .offset(y: headerVisible ? 0 : 20)
    }

    // MARK: - Actions

    private func selectMode(_ mode: AppMode) {
        guard viewModel.selectedMode != mode else { return }
        BloomHerTheme.Haptics.selection()
        withAnimation(BloomHerTheme.Animation.quick) {
            viewModel.selectedMode = mode
        }
    }

    // MARK: - Entrance Animation

    private func runEntranceAnimation() {
        withAnimation(BloomHerTheme.Animation.gentle.delay(0.1)) {
            headerVisible = true
        }
        for index in 0..<cardsVisible.count {
            withAnimation(BloomHerTheme.Animation.gentle.delay(0.25 + Double(index) * 0.12)) {
                cardsVisible[index] = true
            }
        }
    }
}

// MARK: - ModeOption

/// Static display metadata for each AppMode card.
private enum ModeOption: CaseIterable, Identifiable {
    case cycle
    case pregnant
    case ttc

    var id: String { mode.rawValue }

    var mode: AppMode {
        switch self {
        case .cycle:    return .cycle
        case .pregnant: return .pregnant
        case .ttc:      return .ttc
        }
    }

    var title: String {
        switch self {
        case .cycle:    return "Track My Cycle"
        case .pregnant: return "I'm Pregnant"
        case .ttc:      return "Trying to Conceive"
        }
    }

    var description: String {
        switch self {
        case .cycle:    return "Understand your body and predict your periods"
        case .pregnant: return "Track your pregnancy week by week"
        case .ttc:      return "Optimise your fertile window"
        }
    }

    /// Custom asset icon name for this mode.
    var icon: String {
        switch self {
        case .cycle:    return BloomIcons.iconCycle
        case .pregnant: return BloomIcons.iconPregnant
        case .ttc:      return BloomIcons.iconTTC
        }
    }

    /// Custom asset image name.
    var customImage: String? {
        switch self {
        case .cycle:    return BloomIcons.iconCycle
        case .pregnant: return BloomIcons.iconPregnant
        case .ttc:      return BloomIcons.iconTTC
        }
    }

    var accentColor: Color {
        switch self {
        case .cycle:    return BloomColors.sageGreen
        case .pregnant: return BloomColors.accentPeach
        case .ttc:      return BloomColors.accentLavender
        }
    }
}

// MARK: - ModeCard

private struct ModeCard: View {

    let option: ModeOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BloomHerTheme.Spacing.md) {

                // Left accent bar
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous)
                    .fill(option.accentColor)
                    .frame(width: 4)
                    .padding(.vertical, BloomHerTheme.Spacing.xs)

                // Icon
                ZStack {
                    Circle()
                        .fill(option.accentColor.opacity(isSelected ? 0.25 : 0.12))
                        .frame(width: 48, height: 48)

                    Image(option.customImage ?? BloomIcons.flower)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }

                // Text
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(option.title)
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    Text(option.description)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                // Selection checkmark
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? option.accentColor : BloomHerTheme.Colors.textTertiary,
                            lineWidth: 1.5
                        )
                        .frame(width: 26, height: 26)

                    if isSelected {
                        Image(BloomIcons.checkmark)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(option.accentColor)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(BloomHerTheme.Animation.quick, value: isSelected)
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .strokeBorder(
                        isSelected ? option.accentColor.opacity(0.5) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .animation(BloomHerTheme.Animation.standard, value: isSelected)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(option.title). \(option.description)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(option.accentColor.opacity(0.08))
        } else {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8,
                    y: 3
                )
        }
    }
}

// MARK: - Preview

#Preview("Mode Selection") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        ModeSelectionPageView(viewModel: OnboardingViewModel())
    }
    .environment(\.currentCyclePhase, .follicular)
}
