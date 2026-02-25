//
//  RoutineTimerRing.swift
//  BloomHer
//
//  A circular countdown timer ring used in ActiveRoutineView.
//  Features an animated arc, phase-tinted gradient fill, and a large
//  monospaced remaining-time display at the centre.
//

import SwiftUI

// MARK: - RoutineTimerRing

/// Circular progress ring that counts down a pose hold.
///
/// - The outer track is a gray capsule.
/// - The filled arc is a phase-colored gradient that sweeps clockwise.
/// - The center displays the remaining seconds in a large monospaced font.
/// - Three size tiers (`small`, `medium`, `large`) suit different contexts.
struct RoutineTimerRing: View {

    // MARK: - Size Tier

    enum RingSize {
        case small, medium, large

        var diameter: CGFloat {
            switch self {
            case .small:  return 120
            case .medium: return 180
            case .large:  return 220
            }
        }

        var lineWidth: CGFloat {
            switch self {
            case .small:  return 10
            case .medium: return 14
            case .large:  return 18
            }
        }

        var timerFont: Font {
            switch self {
            case .small:  return BloomHerTheme.Typography.headline
            case .medium: return BloomHerTheme.Typography.weekNumber
            case .large:  return BloomHerTheme.Typography.heroNumber
            }
        }
    }

    // MARK: - Configuration

    /// Remaining seconds for the current pose.
    let remainingSeconds: Int
    /// Total seconds for the current pose.
    let totalSeconds: Int
    /// Phase color used to tint the progress arc.
    let phaseColor: Color
    /// Ring size tier.
    var ringSize: RingSize = .large
    /// Whether the timer is currently running.
    var isRunning: Bool = true

    // MARK: - Computed

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(
                    Color.primary.opacity(0.10),
                    style: StrokeStyle(lineWidth: ringSize.lineWidth, lineCap: .round)
                )
                .frame(width: ringSize.diameter, height: ringSize.diameter)

            // Filled arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: ringSize.lineWidth, lineCap: .round)
                )
                .frame(width: ringSize.diameter, height: ringSize.diameter)
                .rotationEffect(.degrees(-90))
                .animation(BloomHerTheme.Animation.standard, value: progress)

            // Ambient glow behind arc tip
            Circle()
                .trim(from: max(0, progress - 0.01), to: progress)
                .stroke(
                    phaseColor.opacity(0.50),
                    style: StrokeStyle(lineWidth: ringSize.lineWidth * 2.2, lineCap: .round)
                )
                .frame(width: ringSize.diameter, height: ringSize.diameter)
                .rotationEffect(.degrees(-90))
                .blur(radius: 6)
                .animation(BloomHerTheme.Animation.standard, value: progress)

            // Center content
            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                Text(formattedTime)
                    .font(ringSize.timerFont)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(BloomHerTheme.Animation.quick, value: remainingSeconds)

                if ringSize != .small {
                    Text(isRunning ? "remaining" : "paused")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
        .frame(width: ringSize.diameter, height: ringSize.diameter)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        if remainingSeconds >= 60 {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%d:%02d", m, s)
        }
        return "\(remainingSeconds)"
    }

    private var progressGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                phaseColor.opacity(0.60),
                phaseColor
            ]),
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }
}

// MARK: - Preview

#Preview("Timer Ring Sizes") {
    VStack(spacing: BloomHerTheme.Spacing.xl) {
        ForEach([
            RoutineTimerRing.RingSize.small,
            .medium,
            .large
        ], id: \.diameter) { size in
            RoutineTimerRing(
                remainingSeconds: 22,
                totalSeconds: 60,
                phaseColor: BloomHerTheme.Colors.primaryRose,
                ringSize: size,
                isRunning: true
            )
        }
    }
    .padding(BloomHerTheme.Spacing.lg)
    .background(BloomHerTheme.Colors.background)
}

#Preview("Timer Ring — Phase Colors") {
    HStack(spacing: BloomHerTheme.Spacing.lg) {
        ForEach(CyclePhase.allCases, id: \.self) { phase in
            RoutineTimerRing(
                remainingSeconds: Int.random(in: 10...59),
                totalSeconds: 60,
                phaseColor: phase.color,
                ringSize: .small
            )
        }
    }
    .padding(BloomHerTheme.Spacing.lg)
    .background(BloomHerTheme.Colors.background)
}
