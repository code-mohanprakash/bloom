//
//  BreathingCircle.swift
//  BloomHer
//
//  Animated breathing exercise visualization.
//  Concentric rings expand on inhale, hold at peak, contract on exhale.
//
//  Phases:
//    1. Inhale   — rings scale from 0.6 → 1.0 (inhaleSeconds)
//    2. Hold     — rings hold at 1.0 (holdSeconds, may be 0)
//    3. Exhale   — rings scale from 1.0 → 0.6 (exhaleSeconds)
//    4. Hold     — rings hold at 0.6 (holdAfterExhaleSeconds, may be 0)
//
//  Customisable timing via initializer. Defaults = box breathing (4-4-4-4).
//

import SwiftUI

// MARK: - BreathingPhase

private enum BreathingPhase: CaseIterable {
    case inhale, holdTop, exhale, holdBottom

    var label: String {
        switch self {
        case .inhale:     return "Breathe In"
        case .holdTop:    return "Hold"
        case .exhale:     return "Breathe Out"
        case .holdBottom: return "Hold"
        }
    }
}

// MARK: - BreathingCircle

struct BreathingCircle: View {

    // MARK: Parameters

    /// Duration of the inhale phase in seconds.
    var inhaleSeconds: Int = 4
    /// Duration of the hold-after-inhale phase (0 = skip).
    var holdSeconds: Int = 4
    /// Duration of the exhale phase in seconds.
    var exhaleSeconds: Int = 4
    /// Duration of the hold-after-exhale phase (0 = skip).
    var holdAfterExhaleSeconds: Int = 4
    /// Whether the exercise is active. Set to false to pause.
    var isActive: Bool = true

    // MARK: State

    @State private var currentPhase: BreathingPhase = .inhale
    @State private var ringScale: CGFloat = 0.6
    @State private var glowOpacity: CGFloat = 0.3
    @State private var countdown: Int = 0
    @State private var timer: Timer? = nil
    @State private var secondsRemaining: Int = 0
    @State private var isRunning: Bool = false

    // MARK: Layout

    private let outerSize: CGFloat = 220
    private let ringColors: [Color] = [
        BloomColors.primaryRose.opacity(0.22),
        BloomColors.primaryRose.opacity(0.35),
        BloomColors.accentLavender.opacity(0.45),
        BloomColors.accentLavender.opacity(0.65)
    ]

    // MARK: Body

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            ZStack {
                // Concentric ambient rings (non-animating background)
                ForEach(0..<4, id: \.self) { i in
                    let base = outerSize - CGFloat(i) * 28
                    Circle()
                        .fill(ringColors[i])
                        .frame(width: base, height: base)
                }

                // Animated outer glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                BloomColors.primaryRose.opacity(glowOpacity),
                                BloomColors.primaryRose.opacity(0)
                            ],
                            center: .center,
                            startRadius: outerSize * 0.22,
                            endRadius: outerSize * 0.55))
                    .frame(width: outerSize * ringScale,
                           height: outerSize * ringScale)
                    .animation(currentPhaseAnimation, value: ringScale)

                // Main animated breathing ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                BloomColors.primaryRose,
                                BloomColors.accentLavender
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                        lineWidth: 4)
                    .frame(
                        width: outerSize * 0.68 * ringScale,
                        height: outerSize * 0.68 * ringScale)
                    .animation(currentPhaseAnimation, value: ringScale)

                // Inner lavender glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                BloomColors.accentLavender.opacity(0.55),
                                BloomColors.accentLavender.opacity(0.15)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: outerSize * 0.28))
                    .frame(
                        width: outerSize * 0.42 * ringScale,
                        height: outerSize * 0.42 * ringScale)
                    .animation(currentPhaseAnimation, value: ringScale)

                // Center content: phase label + timer
                VStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Text(currentPhase.label)
                        .font(BloomHerTheme.Typography.callout)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .contentTransition(.opacity)
                        .animation(BloomHerTheme.Animation.quick, value: currentPhase)

                    Text("\(secondsRemaining)")
                        .font(BloomHerTheme.Typography.heroNumber)
                        .foregroundStyle(BloomColors.primaryRose)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(BloomHerTheme.Animation.quick, value: secondsRemaining)

                    Text("seconds")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
            }
            .frame(width: outerSize, height: outerSize)

            // Phase indicator dots
            phaseIndicator

            // Timing info
            timingLabel
        }
        .onAppear {
            if isActive { startExercise() }
        }
        .onChange(of: isActive) { _, active in
            if active {
                startExercise()
            } else {
                stopExercise()
            }
        }
        .onDisappear { stopExercise() }
    }

    // MARK: - Phase indicator

    private var phaseIndicator: some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            ForEach(activePhasesWithDurations, id: \.0) { (phase, _) in
                Capsule()
                    .fill(currentPhase == phase
                          ? BloomColors.primaryRose
                          : BloomColors.primaryRose.opacity(0.25))
                    .frame(width: currentPhase == phase ? 24 : 8, height: 8)
                    .animation(BloomHerTheme.Animation.quick, value: currentPhase)
            }
        }
    }

    // MARK: - Timing label

    private var timingLabel: some View {
        let parts = activePhasesWithDurations.map { "\($0.0.label): \($0.1)s" }
        return Text(parts.joined(separator: " · "))
            .font(BloomHerTheme.Typography.caption)
            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Active phases (skip 0-second holds)

    private var activePhasesWithDurations: [(BreathingPhase, Int)] {
        var result: [(BreathingPhase, Int)] = [
            (.inhale, inhaleSeconds),
            (.exhale, exhaleSeconds)
        ]
        if holdSeconds > 0 {
            result.insert((.holdTop, holdSeconds), at: 1)
        }
        if holdAfterExhaleSeconds > 0 {
            result.append((.holdBottom, holdAfterExhaleSeconds))
        }
        return result
    }

    // MARK: - Phase animation

    private var currentPhaseAnimation: Animation {
        switch currentPhase {
        case .inhale:
            return .easeInOut(duration: Double(inhaleSeconds))
        case .holdTop, .holdBottom:
            return .linear(duration: 0.1)
        case .exhale:
            return .easeInOut(duration: Double(exhaleSeconds))
        }
    }

    // MARK: - Exercise control

    private func startExercise() {
        guard !isRunning else { return }
        isRunning = true
        transitionToPhase(.inhale)
    }

    private func stopExercise() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func transitionToPhase(_ phase: BreathingPhase) {
        guard isRunning else { return }

        let duration: Int
        switch phase {
        case .inhale:     duration = inhaleSeconds
        case .holdTop:    duration = holdSeconds
        case .exhale:     duration = exhaleSeconds
        case .holdBottom: duration = holdAfterExhaleSeconds
        }

        // If this phase has 0 duration, skip it
        if duration == 0 {
            transitionToPhase(nextPhase(after: phase))
            return
        }

        withAnimation(BloomHerTheme.Animation.quick) {
            currentPhase = phase
            secondsRemaining = duration
        }

        // Set ring scale based on phase
        switch phase {
        case .inhale:
            withAnimation(.easeInOut(duration: Double(duration))) {
                ringScale = 1.0
                glowOpacity = 0.55
            }
        case .holdTop:
            // No scale change — just hold
            break
        case .exhale:
            withAnimation(.easeInOut(duration: Double(duration))) {
                ringScale = 0.6
                glowOpacity = 0.25
            }
        case .holdBottom:
            // No scale change
            break
        }

        // Countdown timer
        timer?.invalidate()
        var elapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            elapsed += 1
            withAnimation(BloomHerTheme.Animation.quick) {
                secondsRemaining = max(0, duration - elapsed)
            }
            if elapsed >= duration {
                t.invalidate()
                transitionToPhase(nextPhase(after: phase))
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func nextPhase(after phase: BreathingPhase) -> BreathingPhase {
        let sequence: [BreathingPhase] = [.inhale, .holdTop, .exhale, .holdBottom]
        let idx = sequence.firstIndex(of: phase) ?? 0
        return sequence[(idx + 1) % sequence.count]
    }
}

// MARK: - Preset configurations

extension BreathingCircle {
    /// Box breathing: 4-4-4-4 (stress relief).
    static var boxBreathing: BreathingCircle {
        BreathingCircle(inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, holdAfterExhaleSeconds: 4)
    }

    /// 4-7-8 relaxation technique.
    static var relaxation478: BreathingCircle {
        BreathingCircle(inhaleSeconds: 4, holdSeconds: 7, exhaleSeconds: 8, holdAfterExhaleSeconds: 0)
    }

    /// Simple diaphragmatic: 4-0-6-0.
    static var diaphragmatic: BreathingCircle {
        BreathingCircle(inhaleSeconds: 4, holdSeconds: 0, exhaleSeconds: 6, holdAfterExhaleSeconds: 0)
    }
}

// MARK: - Preview

#Preview("Breathing Circle") {
    struct PreviewWrapper: View {
        @State private var isActive = true

        var body: some View {
            VStack(spacing: BloomHerTheme.Spacing.xxl) {
                Text("Breathing Exercise")
                    .font(BloomHerTheme.Typography.title2)

                BreathingCircle(
                    inhaleSeconds: 4,
                    holdSeconds: 4,
                    exhaleSeconds: 4,
                    holdAfterExhaleSeconds: 4,
                    isActive: isActive)

                Button {
                    isActive.toggle()
                } label: {
                    Label {
                        Text(isActive ? "Pause" : "Start")
                    } icon: {
                        Image(isActive ? BloomIcons.pause : BloomIcons.play)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                    .font(BloomHerTheme.Typography.callout)
                    .padding()
                    .background(Capsule().fill(BloomColors.primaryRose))
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(hex: "#FFF8F5"))
        }
    }
    return PreviewWrapper()
}
