//
//  BloomCardModifier.swift
//  BloomHer
//
//  A ViewModifier that wraps any view in the standard BloomHer card
//  appearance: padded, rounded, surface-colored, and optionally
//  phase-aware with a colored left accent border.
//
//  Apply via the `.bloomCard(phaseAware:elevation:)` convenience extension
//  on `View` (defined in Utilities/ViewExtensions.swift).
//

import SwiftUI

// MARK: - CardElevation

/// Controls the drop-shadow intensity applied to a BloomHer card.
///
/// In dark mode, shadows are suppressed in favour of a subtle white border;
/// this enum still controls the *light-mode* shadow depth.
public enum CardElevation {
    /// 4 pt radius shadow — for tight, inline cards.
    case small
    /// 8 pt radius shadow — the default card elevation.
    case medium
    /// 16 pt radius shadow — for floating or overlay cards.
    case large
    /// Glassmorphism frosted surface — for cards on gradient/image backgrounds.
    case glass

    // MARK: Internal helpers

    /// The matching `BloomShadow` token for light-mode rendering.
    fileprivate var shadow: BloomShadow {
        switch self {
        case .small:  return BloomHerTheme.Shadows.small
        case .medium: return BloomHerTheme.Shadows.medium
        case .large:  return BloomHerTheme.Shadows.large
        case .glass:  return BloomHerTheme.Glass.shadow
        }
    }

    /// Whether this elevation uses the glassmorphism surface.
    fileprivate var isGlass: Bool { self == .glass }
}

// MARK: - BloomCardModifier

/// Applies the standard BloomHer card chrome to any view.
///
/// Behaviour summary:
/// - Pads content with `BloomHerTheme.Spacing.md`.
/// - Clips to a `RoundedRectangle` with `BloomHerTheme.Radius.large`.
/// - Fills with `surface` (light) or `surface` dark variant — both are
///   already adaptive via `BloomColors.surface`.
/// - In **light mode**: applies the drop shadow matching the `elevation`.
/// - In **dark mode**: no shadow; instead a 1 pt white-at-5% stroke is drawn.
/// - When `phaseAware` is `true`: overlays a 3 pt rounded leading accent
///   bar in the current cycle-phase color.
public struct BloomCardModifier: ViewModifier {

    // MARK: Configuration

    /// When `true`, adds a phase-colored leading accent bar.
    public let phaseAware: Bool

    /// Controls shadow depth (light mode only).
    public let elevation: CardElevation

    /// When `true`, uses a phase-tinted background for visual hierarchy.
    public let tonal: Bool

    // MARK: Environment

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.currentCyclePhase) private var cyclePhase

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .padding(BloomHerTheme.Spacing.md)
            .background(cardBackground)
            .overlay(alignment: .leading) {
                if phaseAware {
                    phaseAccentBar
                }
            }
            .overlay(glassBorder)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .modifier(ShadowModifier(elevation: elevation, colorScheme: colorScheme))
    }

    // MARK: Private helpers

    @ViewBuilder
    private var cardBackground: some View {
        if elevation.isGlass {
            // Glassmorphism layers
            ZStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(.ultraThinMaterial)
                // Inner top highlight
                VStack {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.06 : 0.20),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 36)
                    Spacer()
                }
            }
        } else if tonal {
            // Phase-tinted surface for featured/highlighted cards
            let phaseColor = BloomColors.color(for: cyclePhase)
            ZStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(BloomHerTheme.Colors.surface)
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(phaseColor.opacity(colorScheme == .dark ? 0.08 : 0.10))
            }
        } else {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        }
    }

    @ViewBuilder
    private var glassBorder: some View {
        if elevation.isGlass {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.18 : 0.45),
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        } else if colorScheme == .dark {
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        }
    }

    private var phaseAccentBar: some View {
        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
            .fill(BloomHerTheme.Colors.phase(cyclePhase))
            .frame(width: 3)
            .padding(.vertical, BloomHerTheme.Spacing.xs)
            .padding(.leading, BloomHerTheme.Spacing.xxs)
    }
}

// MARK: - ShadowModifier (private helper)

/// Conditionally applies a drop shadow in light mode only.
private struct ShadowModifier: ViewModifier {
    let elevation: CardElevation
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
        } else {
            content.bloomShadow(elevation.shadow)
        }
    }
}

// MARK: - Preview

#Preview("Bloom Card Modifier") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.lg) {

            // Standard elevations
            ForEach([CardElevation.small, .medium, .large], id: \.self) { elevation in
                Text(elevationLabel(elevation))
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(BloomCardModifier(phaseAware: false, elevation: elevation, tonal: false))
            }

            // Phase-aware card
            Text("Phase-aware card")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(BloomCardModifier(phaseAware: true, elevation: .medium, tonal: false))
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
    .environment(\.currentCyclePhase, .follicular)
}

private func elevationLabel(_ elevation: CardElevation) -> String {
    switch elevation {
    case .small:  return "Small elevation"
    case .medium: return "Medium elevation (default)"
    case .large:  return "Large elevation"
    case .glass:  return "Glass elevation"
    }
}
