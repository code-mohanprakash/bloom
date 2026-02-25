//
//  BloomTabBar.swift
//  BloomHer
//
//  The custom floating tab bar that anchors every screen in the app.
//  Its signature feature is phase-coloured selection: the active tab item
//  and its sliding indicator pill both adopt the current cycle phase accent,
//  creating a cohesive visual connection to the user's body data.
//
//  Layout
//  ------
//  - Floats above safe-area content using a ZStack overlay in MainTabView.
//  - Horizontal insets of Spacing.md shrink it from the screen edges.
//  - Bottom inset equals the safe-area bottom (passed via safeAreaInsets env).
//  - Rounded corners of Radius.xxl (24 pt) give it a pill-like silhouette.
//
//  Accessibility
//  -------------
//  - Each tab item is a button with `.tabBar` accessibility trait.
//  - The selected state is communicated via `.isSelected` trait.
//  - Labels are always visible (not icon-only) to aid identification.
//
//  Animation
//  ---------
//  - The indicator pill slides between items with matchedGeometryEffect
//    driven by a namespace anchored to the bar's coordinate space.
//  - The icon swap (outline -> fill) springs with BloomHerTheme.Animation.quick.
//  - Scale pulse on selection tap reinforces the interaction.
//

import SwiftUI

// MARK: - AppTab

/// Represents each top-level tab in the BloomHer navigation shell.
///
/// Raw `Int` values allow tabs to be ordered and compared by index,
/// which is useful for animating the sliding indicator direction.
enum AppTab: Int, CaseIterable, Hashable {
    case home      = 0
    case calendar  = 1
    case wellness  = 2
    case insights  = 3
    case profile   = 4

    // MARK: Icons

    /// Custom asset name for this tab's icon.
    var customIcon: String {
        switch self {
        case .home:     return "tab-home"
        case .calendar: return "tab-calendar"
        case .wellness: return "tab-wellness"
        case .insights: return "tab-insights"
        case .profile:  return "tab-profile"
        }
    }

    /// The human-readable label shown beneath the tab icon.
    var label: String {
        switch self {
        case .home:     return "Home"
        case .calendar: return "Calendar"
        case .wellness: return "Wellness"
        case .insights: return "Insights"
        case .profile:  return "Profile"
        }
    }

    /// The VoiceOver accessibility label for the tab button.
    var accessibilityLabel: String {
        switch self {
        case .home:     return "Home tab"
        case .calendar: return "Calendar tab"
        case .wellness: return "Wellness tab"
        case .insights: return "Insights tab"
        case .profile:  return "Profile tab"
        }
    }
}

// MARK: - BloomTabBar

/// The floating, phase-tinted custom tab bar used throughout BloomHer.
///
/// Inject `selectedTab` as a `@Binding` from `MainTabView`. The bar reads
/// `currentCyclePhase` from the environment and tints the selected item and
/// sliding indicator with the phase accent color.
struct BloomTabBar: View {

    // MARK: Bindings & Environment

    @Binding var selectedTab: AppTab

    @Environment(\.currentCyclePhase) private var phase
    @Environment(\.colorScheme) private var colorScheme

    // MARK: Animation

    @Namespace private var indicatorNamespace

    // MARK: Scale State (per-tab tap animation)

    /// Tracks which tab is mid-tap so we can apply a brief scale pulse.
    @State private var tappedTab: AppTab? = nil

    // MARK: Constants

    private let barHeight: CGFloat = 64
    private let iconSize: CGFloat  = 22
    private let pillHeight: CGFloat = 3
    private let pillWidth: CGFloat  = 20

    // MARK: Derived Colors

    private var phaseColor: Color {
        BloomColors.color(for: phase)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabItemButton(for: tab)
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, BloomHerTheme.Spacing.xs)
        .background {
            barBackgroundShape
        }
        // Outer horizontal margin shrinks bar from screen edges
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        // Lift off the bottom safe area
        .padding(.bottom, BloomHerTheme.Spacing.xs)
    }

    // MARK: - Tab Item Button

    @ViewBuilder
    private func tabItemButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            selectTab(tab)
        } label: {
            tabItemContent(tab: tab, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .scaleEffect(tappedTab == tab ? 0.88 : 1.0)
        .animation(BloomHerTheme.Animation.quick, value: tappedTab)
        .accessibilityLabel(tab.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Tab Item Content

    @ViewBuilder
    private func tabItemContent(tab: AppTab, isSelected: Bool) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            // Icon — custom asset, no SF Symbols
            Image(tab.customIcon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .opacity(isSelected ? 1.0 : 0.45)
                .colorMultiply(isSelected ? phaseColor : .white)
                // Phase glow behind selected icon
                .shadow(
                    color: isSelected ? phaseColor.opacity(0.40) : .clear,
                    radius: 6,
                    x: 0,
                    y: 2
                )
                .scaleEffect(isSelected ? 1.08 : 1.0)
                .animation(BloomHerTheme.Animation.quick, value: isSelected)
                .animation(BloomHerTheme.Animation.quick, value: phase)

            // Label
            Text(tab.label)
                .font(
                    Font.system(
                        size: 9.5,
                        weight: isSelected ? .semibold : .regular,
                        design: .rounded
                    )
                )
                .foregroundStyle(isSelected ? phaseColor : BloomColors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .animation(BloomHerTheme.Animation.quick, value: isSelected)

            // Sliding indicator pill
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(phaseColor)
                        .frame(width: pillWidth, height: pillHeight)
                        .matchedGeometryEffect(
                            id: "tab_indicator",
                            in: indicatorNamespace
                        )
                        .shadow(
                            color: phaseColor.opacity(0.50),
                            radius: 4,
                            x: 0,
                            y: 1
                        )
                } else {
                    // Reserve consistent height for unselected items so the
                    // bar height doesn't shift as the indicator moves.
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: pillWidth, height: pillHeight)
                }
            }
            .animation(BloomHerTheme.Animation.standard, value: selectedTab)
        }
        .padding(.vertical, BloomHerTheme.Spacing.xs)
        .contentShape(Rectangle())
    }

    // MARK: - Bar Background (Glassmorphism)

    private var barBackgroundShape: some View {
        ZStack {
            // Layer 1: Frosted blur fill
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(.ultraThinMaterial)

            // Layer 2: Subtle phase-tint wash
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(phaseColor.opacity(0.05))

            // Layer 3: Top inner highlight (light refraction)
            VStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.07 : 0.30),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 28)
                Spacer()
            }
        }
        // Layer 4: Glass border
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.18 : 0.50),
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        // Layer 5: Deep shadow for elevation
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.35)
                : phaseColor.opacity(0.15),
            radius: 30,
            x: 0,
            y: 12
        )
    }

    // MARK: - Selection Logic

    /// Selects a tab with haptic feedback and a brief scale pulse.
    private func selectTab(_ tab: AppTab) {
        guard tab != selectedTab else {
            // Tapping the already-active tab: provide lighter feedback only.
            HapticManager.shared.light()
            return
        }

        // Scale-pulse animation
        tappedTab = tab
        Task {
            try? await Task.sleep(for: .milliseconds(120))
            await MainActor.run { tappedTab = nil }
        }

        HapticManager.shared.selection()

        withAnimation(BloomHerTheme.Animation.standard) {
            selectedTab = tab
        }
    }
}

// MARK: - Preview

#Preview("BloomTabBar — Follicular") {
    @Previewable @State var tab: AppTab = .home

    VStack {
        Spacer()
        BloomTabBar(selectedTab: $tab)
    }
    .background(BloomColors.background)
    .environment(\.currentCyclePhase, .follicular)
}

#Preview("BloomTabBar — Menstrual Dark") {
    @Previewable @State var tab: AppTab = .wellness

    VStack {
        Spacer()
        BloomTabBar(selectedTab: $tab)
    }
    .background(BloomColors.background)
    .environment(\.currentCyclePhase, .menstrual)
    .preferredColorScheme(.dark)
}

#Preview("BloomTabBar — Ovulation") {
    @Previewable @State var tab: AppTab = .insights

    VStack {
        Spacer()
        BloomTabBar(selectedTab: $tab)
    }
    .background(BloomColors.background)
    .environment(\.currentCyclePhase, .ovulation)
}

#Preview("BloomTabBar — Luteal") {
    @Previewable @State var tab: AppTab = .calendar

    VStack {
        Spacer()
        BloomTabBar(selectedTab: $tab)
    }
    .background(BloomColors.background)
    .environment(\.currentCyclePhase, .luteal)
}
