//
//  BloomCard.swift
//  BloomHer
//
//  A generic container view that applies the BloomHer card appearance to
//  arbitrary content. Wraps `BloomCardModifier` and optionally renders a
//  phase-colored left accent bar.
//

import SwiftUI

// MARK: - BloomCard

/// A generic card container styled with the BloomHer design language.
///
/// `BloomCard` is the preferred way to present grouped content in BloomHer.
/// It delegates to `BloomCardModifier` for surface color, corner radius,
/// shadow / dark-mode border, and phase-aware accent, so all cards update
/// in lockstep when design tokens change.
///
/// ```swift
/// BloomCard {
///     VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
///         Text("Cycle Day 14").font(BloomHerTheme.Typography.headline)
///         Text("Ovulation phase").font(BloomHerTheme.Typography.body)
///     }
/// }
///
/// // Phase-aware card with leading accent bar:
/// BloomCard(isPhaseAware: true, hasPhaseBorder: true) {
///     PhaseInfoView()
/// }
/// ```
public struct BloomCard<Content: View>: View {

    // MARK: Configuration

    /// When `true`, the `BloomCardModifier` adds a phase-colored 3 pt leading accent.
    public let isPhaseAware: Bool

    /// When `true`, a visible 3 pt rounded left accent bar is rendered independently
    /// of the modifier's subtle accent. Use when you want the bar to be more prominent.
    public let hasPhaseBorder: Bool

    /// When `true`, the card uses a subtle phase-tinted background instead of the
    /// default white/dark surface, creating visual hierarchy for featured content.
    public let isTonal: Bool

    /// The card's shadow depth (light mode only).
    public let elevation: CardElevation

    /// Content built via `@ViewBuilder`.
    private let content: Content

    // MARK: Environment

    @Environment(\.currentCyclePhase) private var cyclePhase

    // MARK: Init

    /// Creates a `BloomCard`.
    ///
    /// - Parameters:
    ///   - isPhaseAware: Adds a subtle phase-colored leading accent via
    ///     `BloomCardModifier`. Defaults to `false`.
    ///   - hasPhaseBorder: Adds a prominent 3 pt phase-colored left bar.
    ///     Defaults to `false`.
    ///   - isTonal: Uses a phase-tinted background for featured cards.
    ///     Defaults to `false`.
    ///   - elevation: Shadow depth in light mode. Defaults to `.medium`.
    ///   - content: The card's body content.
    public init(
        isPhaseAware: Bool = false,
        hasPhaseBorder: Bool = false,
        isTonal: Bool = false,
        elevation: CardElevation = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.isPhaseAware = isPhaseAware
        self.hasPhaseBorder = hasPhaseBorder
        self.isTonal = isTonal
        self.elevation = elevation
        self.content = content()
    }

    // MARK: Body

    public var body: some View {
        HStack(spacing: 0) {
            if hasPhaseBorder {
                accentBar
            }
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .bloomCard(phaseAware: isPhaseAware, elevation: elevation, tonal: isTonal)
    }

    // MARK: Accent Bar

    private var accentBar: some View {
        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
            .fill(BloomHerTheme.Colors.phase(cyclePhase))
            .frame(width: 3)
            .padding(.trailing, BloomHerTheme.Spacing.sm)
    }
}

// MARK: - Preview

#Preview("Bloom Card") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.lg) {

            // Default card
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text("Standard Card").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("No phase accent, medium elevation.").font(BloomHerTheme.Typography.body).foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }

            // Phase-aware card
            BloomCard(isPhaseAware: true) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text("Phase-Aware Card").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Subtle leading accent from the modifier.").font(BloomHerTheme.Typography.body).foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }

            // Card with prominent border
            BloomCard(hasPhaseBorder: true) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text("Phase Border Card").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Prominent 3 pt phase-colored left bar.").font(BloomHerTheme.Typography.body).foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }

            // Large elevation
            BloomCard(elevation: .large) {
                Text("Large Elevation Card").font(BloomHerTheme.Typography.headline).foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
    .environment(\.currentCyclePhase, .ovulation)
}
