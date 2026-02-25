//
//  BloomFlowerGrowth.swift
//  BloomHer
//
//  THE SIGNATURE ELEMENT — a modern phase-aware cycle ring visualization.
//
//  Phase-based rendering:
//    Menstrual  (day 1-5):   Rose tones, drop icon, gentle pulse
//    Follicular (day 6-13):  Green tones, leaf icon, growing ring
//    Ovulation  (day 14-16): Warm peach/gold, sun icon, radiant glow
//    Luteal     (day 17-28): Lavender tones, moon icon, calm pulse
//
//  The outer ring tracks cycle progress (cycleDay / cycleLength). The inner
//  circle pulses gently with phase color. A clean SF Symbol sits in the center.
//

import SwiftUI

// MARK: - BloomFlowerGrowth

struct BloomFlowerGrowth: View {

    let cycleDay: Int
    let cycleLength: Int
    let phase: CyclePhase

    // MARK: State

    @State private var ringProgress: CGFloat = 0
    @State private var hasAppeared: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    // MARK: Layout

    private let containerSize: CGFloat = 240

    // MARK: Computed

    private var cycleProgress: CGFloat {
        guard cycleLength > 0 else { return 0 }
        return CGFloat(cycleDay) / CGFloat(cycleLength)
    }

    private var phaseColor: Color {
        phase.color
    }

    private var innerGradient: [Color] {
        switch phase {
        case .menstrual:
            return [
                BloomColors.primaryRose.opacity(0.18),
                BloomColors.primaryRose.opacity(0.08)
            ]
        case .follicular:
            return [
                BloomColors.sageGreen.opacity(0.18),
                BloomColors.sageGreen.opacity(0.08)
            ]
        case .ovulation:
            return [
                BloomColors.accentPeach.opacity(0.22),
                BloomColors.accentPeach.opacity(0.08)
            ]
        case .luteal:
            return [
                BloomColors.accentLavender.opacity(0.18),
                BloomColors.accentLavender.opacity(0.08)
            ]
        }
    }

    private var glowColor: Color {
        switch phase {
        case .menstrual:  return BloomColors.primaryRose
        case .follicular: return BloomColors.sageGreen
        case .ovulation:  return BloomColors.accentPeach
        case .luteal:     return BloomColors.accentLavender
        }
    }

    // MARK: Body

    var body: some View {
        ZStack {
            // Outer ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(0.12),
                            glowColor.opacity(0)
                        ],
                        center: .center,
                        startRadius: containerSize * 0.28,
                        endRadius: containerSize * 0.5
                    )
                )
                .frame(width: containerSize, height: containerSize)
                .scaleEffect(pulseScale)

            // Track ring (background)
            Circle()
                .stroke(phaseColor.opacity(0.12), lineWidth: 6)
                .frame(width: containerSize * 0.78, height: containerSize * 0.78)

            // Progress ring (foreground)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            phaseColor.opacity(0.5),
                            phaseColor
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * Double(cycleProgress))
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: containerSize * 0.78, height: containerSize * 0.78)
                .rotationEffect(.degrees(-90))

            // Progress dot at end of ring
            if ringProgress > 0.02 {
                Circle()
                    .fill(phaseColor)
                    .frame(width: 12, height: 12)
                    .shadow(color: phaseColor.opacity(0.4), radius: 4, x: 0, y: 0)
                    .offset(
                        x: (containerSize * 0.39) * cos(CGFloat.pi * 2 * ringProgress - .pi / 2),
                        y: (containerSize * 0.39) * sin(CGFloat.pi * 2 * ringProgress - .pi / 2)
                    )
            }

            // Inner filled circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: innerGradient,
                        center: .center,
                        startRadius: 0,
                        endRadius: containerSize * 0.32
                    )
                )
                .frame(width: containerSize * 0.64, height: containerSize * 0.64)
                .scaleEffect(pulseScale)

            // Subtle inner ring
            Circle()
                .strokeBorder(phaseColor.opacity(0.15), lineWidth: 1)
                .frame(width: containerSize * 0.64, height: containerSize * 0.64)

            // Phase icon
            Image(phase.icon)
                .resizable()
                .scaledToFit()
                .frame(width: containerSize * 0.17, height: containerSize * 0.17)
                .scaleEffect(hasAppeared ? 1.0 : 0.6)
                .opacity(hasAppeared ? 1.0 : 0)

            // Decorative phase dots on the ring
            phaseDots
        }
        .frame(width: containerSize, height: containerSize)
        .onAppear {
            withAnimation(BloomHerTheme.Animation.standard.delay(0.1)) {
                ringProgress = cycleProgress
                hasAppeared = true
            }
            startPulse()
        }
        .onChange(of: cycleDay) { _, _ in
            withAnimation(BloomHerTheme.Animation.standard) {
                ringProgress = cycleProgress
            }
        }
        .onChange(of: phase) { _, _ in
            withAnimation(BloomHerTheme.Animation.slow) {
                ringProgress = cycleProgress
            }
        }
    }

    // MARK: - Phase Dots

    /// Small dots on the ring marking phase boundaries.
    private var phaseDots: some View {
        let ringRadius = containerSize * 0.39
        // Approximate phase boundary days (normalized to cycle length)
        let boundaries: [(CGFloat, Color)] = [
            (5.0 / CGFloat(max(cycleLength, 1)), BloomColors.primaryRose.opacity(0.5)),    // end menstrual
            (13.0 / CGFloat(max(cycleLength, 1)), BloomColors.sageGreen.opacity(0.5)),     // end follicular
            (16.0 / CGFloat(max(cycleLength, 1)), BloomColors.accentPeach.opacity(0.5))    // end ovulation
        ]

        return ZStack {
            ForEach(Array(boundaries.enumerated()), id: \.offset) { _, boundary in
                let (fraction, color) = boundary
                let angle = CGFloat.pi * 2 * fraction - .pi / 2
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                    .offset(
                        x: ringRadius * cos(angle),
                        y: ringRadius * sin(angle)
                    )
            }
        }
    }

    // MARK: - Pulse Animation

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 2.8)
            .repeatForever(autoreverses: true)
            .delay(0.5)
        ) {
            pulseScale = 1.04
        }
    }
}

// MARK: - Preview

#Preview("Bloom Cycle Ring") {
    ScrollView {
        VStack(spacing: 24) {
            Text("BloomFlowerGrowth")
                .font(BloomHerTheme.Typography.headline)
                .padding(.top)

            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    BloomFlowerGrowth(cycleDay: 3, cycleLength: 28, phase: .menstrual)
                        .frame(width: 160, height: 160)
                    Text("Menstrual\nDay 3").font(.caption2.rounded())
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: 8) {
                    BloomFlowerGrowth(cycleDay: 10, cycleLength: 28, phase: .follicular)
                        .frame(width: 160, height: 160)
                    Text("Follicular\nDay 10").font(.caption2.rounded())
                        .multilineTextAlignment(.center)
                }
            }
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    BloomFlowerGrowth(cycleDay: 14, cycleLength: 28, phase: .ovulation)
                        .frame(width: 160, height: 160)
                    Text("Ovulation\nDay 14").font(.caption2.rounded())
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: 8) {
                    BloomFlowerGrowth(cycleDay: 22, cycleLength: 28, phase: .luteal)
                        .frame(width: 160, height: 160)
                    Text("Luteal\nDay 22").font(.caption2.rounded())
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
    }
    .background(Color(hex: "#FFF8F5"))
}
