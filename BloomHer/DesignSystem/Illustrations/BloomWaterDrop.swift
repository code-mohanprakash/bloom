//
//  BloomWaterDrop.swift
//  BloomHer
//
//  Kawaii water tracker droplet illustration.
//  Features:
//    • Custom teardrop shape (pointed top, rounded bottom)
//    • Animated wave that rises with fill level
//    • Expression changes at 4 thresholds (sleepy → neutral → happy → excited → blush)
//    • Bobbing animation when idle
//    • Splash particles on new water additions
//    • ml counter label below
//

import SwiftUI

// MARK: - BloomWaterDrop

struct BloomWaterDrop: View {

    /// Current intake in millilitres.
    let currentMl: Int
    /// Daily goal in millilitres.
    let goalMl: Int

    // MARK: State

    @State private var animatedFillRatio: CGFloat = 0
    @State private var waveOffset: CGFloat = 0
    @State private var showSplash: Bool = false
    @State private var bobOffset: CGFloat = 0

    // MARK: Layout constants

    private let dropWidth:  CGFloat = 130
    private let dropHeight: CGFloat = 170

    // MARK: Derived values

    private var fillRatio: CGFloat {
        guard goalMl > 0 else { return 0 }
        return min(CGFloat(currentMl) / CGFloat(goalMl), 1.0)
    }

    private var expression: KawaiiFace.Expression {
        switch fillRatio {
        case 0..<0.25:   return .sleepy
        case 0.25..<0.5: return .neutral
        case 0.5..<0.75: return .happy
        case 0.75..<1.0: return .excited
        default:         return .blush  // 100%
        }
    }

    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [
                BloomColors.waterBlueTint.opacity(0.85),
                BloomColors.waterBlue
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    private var isGoalMet: Bool { currentMl >= goalMl }

    // MARK: Body

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ZStack {
                // Outer drop shell (unfilled outline)
                WaterDropTeardrop()
                    .fill(Color(hex: "#D4EFF8").opacity(0.45))
                    .frame(width: dropWidth, height: dropHeight)

                // Animated water fill clipped to drop shape
                WaterDropTeardrop()
                    .fill(fillGradient)
                    .frame(width: dropWidth, height: dropHeight)
                    .mask(alignment: .bottom) {
                        waveMask
                    }
                    .animation(
                        BloomHerTheme.Animation.slow,
                        value: animatedFillRatio)

                // Drop border
                WaterDropTeardrop()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#5BBCEF").opacity(0.5),
                                     Color(hex: "#2A90C8").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                        lineWidth: 2.0)
                    .frame(width: dropWidth, height: dropHeight)

                // Shine highlight on the drop
                Ellipse()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: dropWidth * 0.22, height: dropHeight * 0.28)
                    .offset(x: -dropWidth * 0.2, y: -dropHeight * 0.18)

                // Kawaii face — positioned in center of drop
                KawaiiFace(expression: expression, size: dropWidth * 0.42)
                    .offset(y: dropHeight * 0.08)

                // Sparkle overlay when goal is met
                if isGoalMet {
                    SparkleParticleView(color: Color(hex: "#5BBCEF"), count: 14)
                        .frame(width: dropWidth, height: dropHeight)
                        .allowsHitTesting(false)
                }

                // Splash trigger overlay
                if showSplash {
                    SplashParticleView(color: BloomColors.waterBlueTint, count: 8)
                        .frame(width: dropWidth, height: dropHeight)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: dropWidth, height: dropHeight)
            .offset(y: bobOffset)
            .onAppear {
                startIdleBob()
                withAnimation(BloomHerTheme.Animation.slow) {
                    animatedFillRatio = fillRatio
                }
            }
            .onChange(of: currentMl) { oldVal, newVal in
                if newVal > oldVal {
                    triggerSplash()
                }
                withAnimation(BloomHerTheme.Animation.slow) {
                    animatedFillRatio = fillRatio
                }
            }

            // ml counter
            mlCounter
        }
    }

    // MARK: - Wave Mask

    /// A rectangle with a sinusoidal top edge that clips the water fill.
    private var waveMask: some View {
        GeometryReader { geo in
            WaveMaskShape(
                fillRatio: animatedFillRatio,
                waveOffset: waveOffset,
                amplitude: 6)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(width: dropWidth, height: dropHeight)
        .onAppear {
            // Continuously animate the wave offset for the wavy surface
            withAnimation(
                .linear(duration: 2.2).repeatForever(autoreverses: false)) {
                waveOffset = dropWidth
            }
        }
    }

    // MARK: - ml Counter

    private var mlCounter: some View {
        HStack(spacing: 4) {
            Text("\(currentMl)")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(Color(hex: "#2A90C8"))
                .contentTransition(.numericText())
                .animation(BloomHerTheme.Animation.standard, value: currentMl)
            Text("/ \(goalMl) ml")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xxs)
        .background(
            Capsule()
                .fill(BloomColors.waterBlueTint.opacity(0.25)))
    }

    // MARK: - Animations

    private func startIdleBob() {
        withAnimation(
            .easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            bobOffset = -6
        }
    }

    private func triggerSplash() {
        showSplash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showSplash = false
        }
    }
}

// MARK: - WaterDropTeardrop Shape

/// Teardrop: pointed top, symmetrically rounded bottom.
/// The point faces upward (drop falling shape).
private struct WaterDropTeardrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2

        // Tip at top-center
        path.move(to: CGPoint(x: cx, y: 0))

        // Right side sweeping down to the wide rounded bottom
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.60),
            control1: CGPoint(x: w * 0.92, y: h * 0.08),
            control2: CGPoint(x: w, y: h * 0.35))

        // Bottom arc (right to left)
        path.addArc(
            center: CGPoint(x: cx, y: h * 0.60),
            radius: w / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: true)

        // Left side back up to tip
        path.addCurve(
            to: CGPoint(x: cx, y: 0),
            control1: CGPoint(x: 0, y: h * 0.35),
            control2: CGPoint(x: w * 0.08, y: h * 0.08))

        path.closeSubpath()
        return path
    }
}

// MARK: - WaveMaskShape

/// Rectangle with a sine-wave top edge for the water fill mask.
private struct WaveMaskShape: Shape {
    var fillRatio: CGFloat
    var waveOffset: CGFloat
    var amplitude: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(fillRatio, waveOffset) }
        set {
            fillRatio = newValue.first
            waveOffset = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let waveY = rect.height * (1.0 - fillRatio)
        var path = Path()

        // Trace the sinusoidal top edge
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waveY))

        let step: CGFloat = 4
        var x: CGFloat = 0
        while x <= rect.width {
            let relX = x + waveOffset
            let y = waveY + sin(relX / rect.width * .pi * 3) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("Water Drop") {
    struct PreviewWrapper: View {
        @State private var ml = 750

        var body: some View {
            VStack(spacing: 32) {
                Text("BloomWaterDrop")
                    .font(BloomHerTheme.Typography.headline)

                BloomWaterDrop(currentMl: ml, goalMl: 2000)

                // Controls
                VStack(spacing: 12) {
                    Text("Tap to add 250 ml")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    Button {
                        ml = min(ml + 250, 2000)
                        BloomHerTheme.Haptics.medium()
                    } label: {
                        Label {
                            Text("+ 250 ml")
                        } icon: {
                            Image(BloomIcons.drop)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                        }
                        .font(BloomHerTheme.Typography.callout)
                        .padding()
                        .background(Capsule().fill(BloomColors.waterBlueTint.opacity(0.4)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        ml = 0
                    } label: {
                        Text("Reset")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(hex: "#FFF8F5"))
        }
    }
    return PreviewWrapper()
}
