//
//  BloomGlassModifier.swift
//  BloomHer
//
//  Glassmorphism view modifier and helper views.
//  Apply .bloomGlass() to any view for the frosted-glass effect.
//
//  Usage:
//    VStack { content }
//        .bloomGlass()
//
//    // Custom corner radius & stroke:
//    HStack { content }
//        .bloomGlass(radius: 24, stroke: 0.5)
//
//    // Phase-tinted glass:
//    VStack { content }
//        .bloomGlass(tint: phase.color.opacity(0.08))
//

import SwiftUI

// MARK: - BloomGlassModifier

/// Applies a frosted-glass (glassmorphism) appearance to any view.
///
/// Creates a layered effect:
/// 1. `.ultraThinMaterial` blur fill
/// 2. Optional phase-color tint overlay
/// 3. White stroke border simulating light refraction
/// 4. Inner top highlight gradient
/// 5. Drop shadow for depth
public struct BloomGlassModifier: ViewModifier {

    var radius: CGFloat
    var material: Material
    var tint: Color
    var strokeWidth: CGFloat
    var showShadow: Bool

    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        content
            .background(glassBackground)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(glassBorder)
            .shadow(
                color: showShadow ? Color.black.opacity(colorScheme == .dark ? 0.25 : 0.10) : .clear,
                radius: 24,
                x: 0,
                y: 10
            )
    }

    // MARK: Background layers

    @ViewBuilder
    private var glassBackground: some View {
        ZStack {
            // Layer 1: Blur material
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(material)

            // Layer 2: Phase/brand tint
            if tint != .clear {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(tint)
            }

            // Layer 3: Inner top highlight — simulates light catching the glass
            VStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.06 : 0.18),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 40)
                Spacer()
            }
        }
    }

    // MARK: Border

    private var glassBorder: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.15 : 0.40),
                        Color.white.opacity(colorScheme == .dark ? 0.05 : 0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: strokeWidth
            )
    }
}

// MARK: - View Extension

public extension View {

    /// Applies the BloomHer glassmorphism effect.
    ///
    /// - Parameters:
    ///   - radius: Corner radius. Defaults to `BloomHerTheme.Radius.large`.
    ///   - material: Blur material tier. Defaults to `.ultraThinMaterial`.
    ///   - tint: Optional color overlay over the blur. Defaults to `.clear`.
    ///   - stroke: Border width. Defaults to `1`.
    ///   - shadow: Whether to add depth shadow. Defaults to `true`.
    func bloomGlass(
        radius: CGFloat = BloomHerTheme.Radius.large,
        material: Material = BloomHerTheme.Glass.ultraThin,
        tint: Color = .clear,
        stroke: CGFloat = 1.0,
        shadow: Bool = true
    ) -> some View {
        modifier(BloomGlassModifier(
            radius: radius,
            material: material,
            tint: tint,
            strokeWidth: stroke,
            showShadow: shadow
        ))
    }
}

// MARK: - GlassCard

/// A convenience glass-morphism card container.
///
/// Equivalent to `BloomCard` but with a frosted-glass surface instead of solid fill.
/// Best used on top of gradient or image backgrounds where the blur has material to work with.
///
/// ```swift
/// GlassCard {
///     Text("Today's Affirmation")
///         .font(BloomHerTheme.Typography.headline)
/// }
///
/// // Phase-tinted:
/// GlassCard(tint: phase.color.opacity(0.08)) {
///     PhaseInfoView()
/// }
/// ```
public struct GlassCard<Content: View>: View {

    var radius: CGFloat
    var tint: Color
    var material: Material
    var hasPhaseBorder: Bool
    let content: Content

    @Environment(\.currentCyclePhase) private var phase

    public init(
        radius: CGFloat = BloomHerTheme.Radius.large,
        tint: Color = .clear,
        material: Material = BloomHerTheme.Glass.ultraThin,
        hasPhaseBorder: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.radius = radius
        self.tint = tint
        self.material = material
        self.hasPhaseBorder = hasPhaseBorder
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) {
            if hasPhaseBorder {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .fill(BloomHerTheme.Colors.phase(phase))
                    .frame(width: 3)
                    .padding(.trailing, BloomHerTheme.Spacing.sm)
            }
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .bloomGlass(radius: radius, material: material, tint: tint)
    }
}

// MARK: - Preview

#Preview("Glass Modifier") {
    ZStack {
        // Background to make glass effect visible
        LinearGradient(
            colors: [BloomColors.primaryRose, BloomColors.accentLavender, BloomColors.sageGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.lg) {

                // Basic glass card
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Standard Glass")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(.white)
                    Text("ultraThinMaterial + white stroke + inner highlight")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(BloomHerTheme.Spacing.md)
                .bloomGlass()

                // GlassCard with phase border
                GlassCard(
                    tint: BloomColors.primaryRose.opacity(0.08),
                    hasPhaseBorder: true
                ) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        Text("Phase-Tinted Glass Card")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(.white)
                        Text("With rose tint and phase accent bar")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(BloomHerTheme.Spacing.md)
                }

                // Larger radius
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Large Radius Glass")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(.white)
                    Text("cornerRadius: 24pt (xxl)")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(BloomHerTheme.Spacing.lg)
                .bloomGlass(radius: BloomHerTheme.Radius.xxl)

                // Thin material variant
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Text("Regular Material Glass")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(.white)
                    Text("thinMaterial — slightly more opaque")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(BloomHerTheme.Spacing.md)
                .bloomGlass(material: .thinMaterial)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }
    .environment(\.currentCyclePhase, .follicular)
}
