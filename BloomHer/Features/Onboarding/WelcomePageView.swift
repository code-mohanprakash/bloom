//
//  WelcomePageView.swift
//  BloomHer
//
//  First impression page — introduces the BloomHer brand with an ascending
//  dove illustration, staggered text entrance, and a rose radial glow.
//
//  Animation sequence (triggered on .onAppear):
//    0.0 s — radial background glow starts fading in
//    0.15 s — dove scales up from 0.05 → 1.0 (spring)
//    0.7 s — sparkle particles fire
//    0.5 s — "BloomHer" text fades + slides up
//    0.8 s — tagline fades + slides up
//    1.2 s — "Get Started" button fades in
//

import SwiftUI

// MARK: - WelcomePageView

struct WelcomePageView: View {

    // MARK: Input

    @Bindable var viewModel: OnboardingViewModel

    // MARK: Animation State

    @State private var doveScale:     CGFloat = 0.05
    @State private var doveOpacity:   Double  = 0.0
    @State private var glowOpacity:   Double  = 0.0
    @State private var titleOpacity:  Double  = 0.0
    @State private var titleOffset:   CGFloat = 28
    @State private var taglineOpacity: Double = 0.0
    @State private var taglineOffset: CGFloat = 20
    @State private var buttonOpacity: Double  = 0.0
    @State private var buttonOffset:  CGFloat = 16
    @State private var showSparkles:  Bool    = false

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: BloomHerTheme.Spacing.massive)

                // Dove illustration
                doveIllustration

                Spacer(minLength: BloomHerTheme.Spacing.xxl)

                // Brand text
                VStack(spacing: BloomHerTheme.Spacing.sm) {
                    Text("BloomHer")
                        .font(BloomHerTheme.Typography.largeTitle)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)

                    Text("Your Body. Every Phase.\nOne Beautiful App.")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(BloomHerTheme.Spacing.xxs)
                        .opacity(taglineOpacity)
                        .offset(y: taglineOffset)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xxl)

                Spacer(minLength: BloomHerTheme.Spacing.xxxl)

                // CTA button
                BloomButton(
                    "Get Started",
                    style: .primary,
                    size: .large,
                    icon: BloomIcons.sparkles,
                    isFullWidth: true
                ) {
                    viewModel.advance()
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)

                Spacer(minLength: BloomHerTheme.Spacing.massive + BloomHerTheme.Spacing.xl)
            }
        }
        .onAppear(perform: runEntranceAnimation)
    }

    // MARK: - Dove Illustration

    private var doveIllustration: some View {
        ZStack {
            // Photorealistic hero — sits behind glow and dove, fades in with the glow
            Image(BloomIcons.heroOnboarding)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    BloomHerTheme.Colors.background.opacity(0.30),
                                    BloomHerTheme.Colors.background.opacity(0.65)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .opacity(glowOpacity)
                .allowsHitTesting(false)

            // Radial rose glow — expands from centre
            RadialGradient(
                colors: [
                    BloomHerTheme.Colors.primaryRose.opacity(0.18),
                    BloomHerTheme.Colors.accentPeach.opacity(0.08),
                    BloomHerTheme.Colors.primaryRose.opacity(0.0)
                ],
                center: .center,
                startRadius: 20,
                endRadius: 160
            )
            .frame(width: 300, height: 300)
            .opacity(glowOpacity)

            // Sparkle particles — appear after the dove scales in
            if showSparkles {
                SparkleParticleView(color: BloomHerTheme.Colors.accentPeach, count: 18)
                    .frame(width: 280, height: 280)
                    .allowsHitTesting(false)

                SparkleParticleView(
                    color: BloomHerTheme.Colors.primaryRose.opacity(0.7),
                    count: 10
                )
                .frame(width: 200, height: 200)
                .allowsHitTesting(false)
            }

            // Dove — scales up and fades in
            Image(BloomIcons.doveHero)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(doveScale)
                .opacity(doveOpacity)
        }
        .frame(width: 300, height: 300)
    }

    // MARK: - Entrance Animation

    private func runEntranceAnimation() {
        // Glow background
        withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
            glowOpacity = 1.0
        }

        // Dove scales up
        withAnimation(BloomHerTheme.Animation.flowerGrow.delay(0.15)) {
            doveScale   = 1.0
            doveOpacity = 1.0
        }

        // Sparkles fire after dove settles
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.7))
            withAnimation(BloomHerTheme.Animation.quick) {
                showSparkles = true
            }
        }

        // "BloomHer" title
        withAnimation(BloomHerTheme.Animation.gentle.delay(0.5)) {
            titleOpacity = 1.0
            titleOffset  = 0
        }

        // Tagline
        withAnimation(BloomHerTheme.Animation.gentle.delay(0.8)) {
            taglineOpacity = 1.0
            taglineOffset  = 0
        }

        // Button
        withAnimation(BloomHerTheme.Animation.gentle.delay(1.2)) {
            buttonOpacity = 1.0
            buttonOffset  = 0
        }
    }
}

// MARK: - Preview

#Preview("Welcome Page") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        WelcomePageView(viewModel: OnboardingViewModel())
    }
    .environment(\.currentCyclePhase, .follicular)
}
