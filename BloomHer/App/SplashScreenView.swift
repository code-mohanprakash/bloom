//
//  SplashScreenView.swift
//  BloomHer
//
//  Animated launch screen shown briefly when the app cold-starts.
//  A dove silhouette draws itself, fills with a rose-peach gradient,
//  then the "BloomHer" wordmark and tagline fade in before the view
//  yields to RootView (onboarding or main tab shell).
//
//  Animation timeline (~1.8 s total):
//    0.00 s — dove outline begins drawing (trim 0 → 1, 0.8 s)
//    0.20 s — radial glow pulse starts
//    0.75 s — gradient fill fades in (0.3 s)
//    0.95 s — wordmark fades + slides up (0.3 s)
//    1.15 s — tagline fades in (0.25 s)
//

import SwiftUI

// MARK: - SplashScreenView

/// A branded splash screen that animates on cold launch.
///
/// The dove outline self-draws with a trim animation, then fills with the
/// brand rose-peach gradient.  The wordmark and tagline stagger in
/// afterward.  Timing is driven by `onAppear`; dismissal is handled
/// externally by `BloomHerApp`.
struct SplashScreenView: View {

    // MARK: Animation State

    /// Opacity of the dove image as it blooms into view.
    @State private var doveOpacity:     Double  = 0.0
    /// Scale of the dove image (blooms from 0.6 → 1.0).
    @State private var doveScale:       CGFloat = 0.6
    /// Scale factor of the outer radial glow (pulses for ambience).
    @State private var glowScale:       CGFloat = 0.85
    /// Opacity of the radial glow.
    @State private var glowOpacity:     Double  = 0.0
    /// Opacity of the wordmark.
    @State private var textOpacity:     Double  = 0.0
    /// Vertical offset of the wordmark (slides up as it appears).
    @State private var textOffset:      CGFloat = 14
    /// Opacity of the tagline.
    @State private var taglineOpacity:  Double  = 0.0

    // MARK: Body

    var body: some View {
        ZStack {
            // Warm cream background matching the app
            BloomHerTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: BloomHerTheme.Spacing.lg) {
                Spacer()

                // Dove illustration
                doveHero
                    .frame(width: 140, height: 140)

                // Wordmark + tagline
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    Text("BloomHer")
                        .font(BloomHerTheme.Typography.weekNumber)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                        .opacity(textOpacity)
                        .offset(y: textOffset)

                    Text("Your body, your rhythm")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .opacity(taglineOpacity)
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear(perform: runSplashAnimation)
    }

    // MARK: - Dove Hero

    private var doveHero: some View {
        ZStack {
            // Outer radial glow — pulses gently for ambience
            RadialGradient(
                colors: [
                    BloomHerTheme.Colors.primaryRose.opacity(0.22),
                    BloomHerTheme.Colors.accentPeach.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 90
            )
            .frame(width: 200, height: 200)
            .scaleEffect(glowScale)
            .opacity(glowOpacity)

            // Inner warm accent halo
            Circle()
                .fill(BloomHerTheme.Colors.accentPeach.opacity(0.10))
                .frame(width: 120, height: 120)
                .opacity(glowOpacity)

            // Dove image — blooms into view with scale + fade
            Image(BloomIcons.doveHero)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .scaleEffect(doveScale)
                .opacity(doveOpacity)
        }
    }

    // MARK: - Animation Sequence

    private func runSplashAnimation() {
        // 1. Radial glow fades in behind the dove
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            glowOpacity = 1.0
        }

        // 2. Glow pulse (subtle, repeating)
        withAnimation(
            BloomHerTheme.Animation.pulse.delay(0.2)
        ) {
            glowScale = 1.12
        }

        // 3. Dove blooms into view — scales up with a spring
        withAnimation(BloomHerTheme.Animation.flowerGrow.delay(0.15)) {
            doveScale   = 1.0
            doveOpacity = 1.0
        }

        // 5. Wordmark slides up and fades in
        withAnimation(BloomHerTheme.Animation.gentle.delay(0.95)) {
            textOpacity = 1.0
            textOffset  = 0
        }

        // 6. Tagline fades in
        withAnimation(BloomHerTheme.Animation.gentle.delay(1.15)) {
            taglineOpacity = 1.0
        }
    }
}

// MARK: - Preview

#Preview("Splash Screen") {
    SplashScreenView()
}
