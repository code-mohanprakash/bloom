//
//  PrivacyPromisePageView.swift
//  BloomHer
//
//  Page 3 — a full-screen trust-building page with an animated lock
//  illustration, three staggered privacy promise bullets, and a brand
//  philosophy quote.
//
//  Animation sequence on .onAppear:
//    0.0s — background tint fades in
//    0.2s — lock icon scales in with spring
//    0.5s — glow pulse begins
//    0.7s — title fades + slides up
//    1.0s — bullet 1 appears
//    1.3s — bullet 2 appears
//    1.6s — bullet 3 appears
//    2.0s — quote fades in
//    2.3s — Continue button fades in
//

import SwiftUI

// MARK: - PrivacyPromisePageView

struct PrivacyPromisePageView: View {

    // MARK: Input

    @Bindable var viewModel: OnboardingViewModel

    // MARK: Animation state

    @State private var lockScale: CGFloat        = 0.3
    @State private var lockOpacity: Double       = 0
    @State private var glowOpacity: Double       = 0
    @State private var titleVisible: Bool        = false
    @State private var bulletVisible: [Bool]     = [false, false, false]
    @State private var quoteVisible: Bool        = false
    @State private var buttonVisible: Bool       = false
    @State private var glowPulsing: Bool         = false

    // MARK: Privacy bullets

    private let bullets: [(icon: String, text: String)] = [
        (BloomIcons.lockShield,   "All health data stored on your device"),
        (BloomIcons.xmarkCircle,  "No third-party tracking or analytics"),
        (BloomIcons.icloud,       "iCloud sync is optional and encrypted")
    ]

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: BloomHerTheme.Spacing.massive)

                // ── Lock illustration ───────────────────────────────────────
                lockIllustration

                Spacer(minLength: BloomHerTheme.Spacing.xxl)

                // ── Title ───────────────────────────────────────────────────
                Text("Your data stays with you.")
                    .font(BloomHerTheme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BloomHerTheme.Spacing.xl)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 16)

                Spacer(minLength: BloomHerTheme.Spacing.xxl)

                // ── Privacy bullets ─────────────────────────────────────────
                VStack(spacing: BloomHerTheme.Spacing.md) {
                    ForEach(Array(bullets.enumerated()), id: \.offset) { index, bullet in
                        PrivacyBulletRow(
                            icon: bullet.icon,
                            text: bullet.text,
                            isVisible: bulletVisible[index]
                        )
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)

                Spacer(minLength: BloomHerTheme.Spacing.xxl)

                // ── Quote ───────────────────────────────────────────────────
                quoteBlock
                    .padding(.horizontal, BloomHerTheme.Spacing.xxl)
                    .opacity(quoteVisible ? 1 : 0)

                Spacer(minLength: BloomHerTheme.Spacing.xxxl)

                // ── Continue button ─────────────────────────────────────────
                BloomButton(
                    "I understand",
                    style: .primary,
                    size: .large,
                    icon: BloomIcons.checkmarkShield,
                    isFullWidth: true
                ) {
                    viewModel.advance()
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
                .opacity(buttonVisible ? 1 : 0)
                .offset(y: buttonVisible ? 0 : 12)

                BloomButton("Back", style: .ghost, size: .medium, icon: BloomIcons.chevronLeft) {
                    viewModel.goBack()
                }
                .opacity(buttonVisible ? 1 : 0)

                Spacer(minLength: BloomHerTheme.Spacing.massive + BloomHerTheme.Spacing.xl)
            }
        }
        .onAppear(perform: runEntranceAnimation)
    }

    // MARK: - Lock Illustration

    private var lockIllustration: some View {
        ZStack {
            // Animated glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            BloomHerTheme.Colors.primaryRose.opacity(glowPulsing ? 0.18 : 0.08),
                            BloomHerTheme.Colors.primaryRose.opacity(0)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: glowPulsing ? 110 : 80
                    )
                )
                .frame(width: 220, height: 220)
                .opacity(glowOpacity)
                .animation(
                    BloomHerTheme.Animation.breath,
                    value: glowPulsing
                )

            // Secondary soft peach ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            BloomHerTheme.Colors.accentPeach.opacity(glowPulsing ? 0.12 : 0.05),
                            BloomHerTheme.Colors.accentPeach.opacity(0)
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .opacity(glowOpacity)
                .animation(
                    BloomHerTheme.Animation.breath.delay(0.5),
                    value: glowPulsing
                )

            // Lock illustration
            Image(BloomIcons.lockShield)
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .scaleEffect(lockScale)
                .opacity(lockOpacity)
                .shadow(
                    color: BloomHerTheme.Colors.primaryRose.opacity(0.30),
                    radius: 16,
                    y: 6
                )

            // Kawaii face overlay on the shield body
            KawaiiFace(expression: .happy, size: 36)
                .offset(y: 10)
                .scaleEffect(lockScale)
                .opacity(lockOpacity)
        }
    }

    // MARK: - Quote

    private var quoteBlock: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            Rectangle()
                .fill(BloomHerTheme.Colors.primaryRose.opacity(0.3))
                .frame(width: 32, height: 2)
                .cornerRadius(1)

            Text("\"We built BloomHer because we believe your body is your business.\"")
                .font(BloomHerTheme.Typography.callout)
                .italic()
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(BloomHerTheme.Spacing.xxxs)

            Rectangle()
                .fill(BloomHerTheme.Colors.primaryRose.opacity(0.3))
                .frame(width: 32, height: 2)
                .cornerRadius(1)
        }
    }

    // MARK: - Entrance Animation

    private func runEntranceAnimation() {
        // Lock appears
        withAnimation(BloomHerTheme.Animation.flowerGrow.delay(0.15)) {
            lockScale   = 1.0
            lockOpacity = 1.0
        }

        // Glow fades in, then starts pulsing
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            glowOpacity = 1.0
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))
            glowPulsing = true
        }

        // Title
        withAnimation(BloomHerTheme.Animation.gentle.delay(0.7)) {
            titleVisible = true
        }

        // Staggered bullets
        for index in 0..<bulletVisible.count {
            withAnimation(BloomHerTheme.Animation.gentle.delay(1.0 + Double(index) * 0.3)) {
                bulletVisible[index] = true
            }
        }

        // Quote
        withAnimation(BloomHerTheme.Animation.gentle.delay(2.0)) {
            quoteVisible = true
        }

        // Button
        withAnimation(BloomHerTheme.Animation.gentle.delay(2.3)) {
            buttonVisible = true
        }
    }
}

// MARK: - PrivacyBulletRow

private struct PrivacyBulletRow: View {

    let icon: String
    let text: String
    let isVisible: Bool

    var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            // Animated checkmark badge
            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.sageGreen.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(BloomHerTheme.Colors.sageGreen)
            }

            Text(text)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Image(BloomIcons.checkmarkCircle)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(BloomHerTheme.Colors.sageGreen)
        }
        .padding(BloomHerTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .animation(BloomHerTheme.Animation.gentle, value: isVisible)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Privacy Promise") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        PrivacyPromisePageView(viewModel: OnboardingViewModel())
    }
    .environment(\.currentCyclePhase, .follicular)
}
