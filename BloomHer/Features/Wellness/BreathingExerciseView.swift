//
//  BreathingExerciseView.swift
//  BloomHer
//
//  Guided breathing exercise screen.
//  Features:
//  • Pattern selector (Box, 4-7-8, Calm)
//  • Large BreathingCircle animation centred on screen
//  • Duration selector (2, 5, 10 minutes)
//  • Elapsed timer and cycle counter
//  • Start / Pause / Reset controls
//  • Haptic feedback on phase transitions
//  • Completion celebration sheet
//

import SwiftUI

// MARK: - BreathingExerciseView

struct BreathingExerciseView: View {

    // MARK: State

    @State private var selectedPatternIndex: Int = 0
    @State private var selectedDurationIndex: Int = 1
    @State private var isActive: Bool = false
    @State private var isPaused: Bool = false
    @State private var elapsedSeconds: Int = 0
    @State private var currentCycle: Int = 0
    @State private var showCompletion: Bool = false
    @State private var sessionTimer: Timer?
    @State private var completedSeconds: Int = 0

    // MARK: Constants

    private let patterns: [BreathingPattern] = [
        .boxBreathing,
        .fourSevenEight,
        .calmBreath,
    ]

    private let durations: [(String, Int)] = [
        ("2 min", 120),
        ("5 min", 300),
        ("10 min", 600),
    ]

    private var selectedPattern: BreathingPattern { patterns[selectedPatternIndex] }
    private var selectedDurationSeconds: Int { durations[selectedDurationIndex].1 }

    private var progress: Double {
        guard selectedDurationSeconds > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(selectedDurationSeconds), 1.0)
    }

    private var cyclesInPattern: Int {
        guard selectedPattern.totalCycleSeconds > 0 else { return 0 }
        return selectedDurationSeconds / selectedPattern.totalCycleSeconds
    }

    private var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private var remainingFormatted: String {
        let remaining = max(selectedDurationSeconds - elapsedSeconds, 0)
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: Body

    var body: some View {
        ZStack {
            // Ambient background
            ambientBackground

            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.xl) {
                    // Pattern selector
                    if !isActive {
                        patternSelector
                            .staggeredAppear(index: 0)
                    }

                    // Ambient hero image — visible only before session starts
                    if !isActive {
                        breathingHeroBanner
                            .staggeredAppear(index: 1)
                    }

                    // Breathing circle
                    breathingCircleSection
                        .staggeredAppear(index: isActive ? 0 : 2)

                    // Stats row
                    statsRow
                        .staggeredAppear(index: 2)

                    // Duration selector
                    if !isActive {
                        durationSelector
                            .staggeredAppear(index: 3)
                    }

                    // Controls
                    controlsSection
                        .staggeredAppear(index: 4)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
        }
        .bloomNavigation("Breathing")
        .bloomBackground()
        .sheet(isPresented: $showCompletion) {
            CompletionSheet(
                pattern: selectedPattern,
                durationSeconds: completedSeconds,
                onDismiss: {
                    showCompletion = false
                    resetExercise()
                }
            )
            .bloomSheet(detents: [.medium])
        }
        .onDisappear { stopSession() }
    }

    // MARK: - Ambient Background

    private var ambientBackground: some View {
        LinearGradient(
            colors: [
                BloomHerTheme.Colors.accentLavender.opacity(0.08),
                BloomHerTheme.Colors.background,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(BloomHerTheme.Animation.slow, value: isActive)
    }

    // MARK: - Hero Banner

    private var breathingHeroBanner: some View {
        Image(BloomIcons.heroBreathing)
            .resizable()
            .scaledToFill()
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .overlay(
                LinearGradient(
                    colors: [.clear, BloomHerTheme.Colors.background.opacity(0.50)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            )
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    // MARK: - Pattern Selector

    private var patternSelector: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Choose a Pattern")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            BloomSegmentedControl(
                options: patterns.map(\.name),
                selectedIndex: $selectedPatternIndex
            )

            // Pattern description
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text(selectedPattern.name)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(selectedPattern.description)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        phaseTimingChip("In", seconds: selectedPattern.inhaleSeconds, color: BloomHerTheme.Colors.sageGreen)
                        if selectedPattern.holdSeconds > 0 {
                            phaseTimingChip("Hold", seconds: selectedPattern.holdSeconds, color: BloomHerTheme.Colors.accentPeach)
                        }
                        phaseTimingChip("Out", seconds: selectedPattern.exhaleSeconds, color: BloomHerTheme.Colors.accentLavender)
                        if selectedPattern.holdAfterExhaleSeconds > 0 {
                            phaseTimingChip("Rest", seconds: selectedPattern.holdAfterExhaleSeconds, color: BloomHerTheme.Colors.primaryRose.opacity(0.6))
                        }
                    }
                    .padding(.top, BloomHerTheme.Spacing.xxs)
                }
                .padding(BloomHerTheme.Spacing.md)
            }
            .animation(BloomHerTheme.Animation.standard, value: selectedPatternIndex)
        }
    }

    private func phaseTimingChip(_ label: String, seconds: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            Text("\(seconds)s")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(color)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                .fill(color.opacity(0.12))
        )
    }

    // MARK: - Breathing Circle

    private var breathingCircleSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            BreathingCircle(
                inhaleSeconds: selectedPattern.inhaleSeconds,
                holdSeconds: selectedPattern.holdSeconds,
                exhaleSeconds: selectedPattern.exhaleSeconds,
                holdAfterExhaleSeconds: selectedPattern.holdAfterExhaleSeconds,
                isActive: isActive && !isPaused
            )
            .frame(width: 280, height: 280)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(label: "Elapsed", value: elapsedFormatted, icon: BloomIcons.clock)
            Divider().frame(height: 40)
            statItem(label: "Remaining", value: remainingFormatted, icon: BloomIcons.timer)
            Divider().frame(height: 40)
            statItem(label: "Cycles", value: "\(currentCycle) / \(cyclesInPattern)", icon: BloomIcons.refresh)
        }
        .padding(.vertical, BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    private func statItem(label: String, value: String, icon: String) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxs) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(value)
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(BloomHerTheme.Animation.quick, value: value)
            Text(label)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Duration Selector

    private var durationSelector: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Duration")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            BloomSegmentedControl(
                options: durations.map(\.0),
                selectedIndex: $selectedDurationIndex
            )
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            if isActive {
                // Pause / Resume
                BloomButton(
                    isPaused ? "Resume" : "Pause",
                    style: .outline,
                    icon: isPaused ? BloomIcons.play : BloomIcons.pause,
                    isFullWidth: true
                ) {
                    togglePause()
                }

                // Reset
                BloomButton("Reset", style: .ghost, icon: BloomIcons.refresh, isFullWidth: true) {
                    resetExercise()
                }
            } else {
                // Start
                BloomButton("Start", style: .primary, icon: BloomIcons.play, isFullWidth: true) {
                    startSession()
                }
                .accessibilityHint("Begins a guided breathing session")
            }
        }
    }

    // MARK: - Session Logic

    private func startSession() {
        elapsedSeconds = 0
        currentCycle = 0
        isActive = true
        isPaused = false
        startSessionTimer()
        BloomHerTheme.Haptics.medium()
    }

    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopSessionTimer()
            BloomHerTheme.Haptics.light()
        } else {
            startSessionTimer()
            BloomHerTheme.Haptics.medium()
        }
    }

    private func resetExercise() {
        stopSession()
        isActive = false
        isPaused = false
        elapsedSeconds = 0
        currentCycle = 0
    }

    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1

            // Track cycle completions
            if selectedPattern.totalCycleSeconds > 0 {
                currentCycle = elapsedSeconds / selectedPattern.totalCycleSeconds
            }

            // Haptic on each full cycle
            if selectedPattern.totalCycleSeconds > 0 && elapsedSeconds % selectedPattern.totalCycleSeconds == 0 {
                BloomHerTheme.Haptics.light()
            }

            // Check completion
            if elapsedSeconds >= selectedDurationSeconds {
                completedSeconds = elapsedSeconds
                stopSession()
                isActive = false
                BloomHerTheme.Haptics.success()
                withAnimation(BloomHerTheme.Animation.standard) {
                    showCompletion = true
                }
            }
        }
        RunLoop.main.add(sessionTimer!, forMode: .common)
    }

    private func stopSession() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    private func stopSessionTimer() {
        stopSession()
    }

    private func stopSessionFully() {
        stopSession()
        isActive = false
        isPaused = false
    }
}

// MARK: - CompletionSheet

private struct CompletionSheet: View {
    let pattern: BreathingPattern
    let durationSeconds: Int
    let onDismiss: () -> Void

    @State private var sparkleOpacity: Double = 0

    var body: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.sageGreen.opacity(0.2))
                    .frame(width: 120, height: 120)

                KawaiiFace(expression: .blush, size: 80)

                SparkleParticleView(color: BloomHerTheme.Colors.accentPeach, count: 16)
                    .frame(width: 160, height: 160)
                    .opacity(sparkleOpacity)
            }

            VStack(spacing: BloomHerTheme.Spacing.sm) {
                Text("Session Complete!")
                    .font(BloomHerTheme.Typography.title1)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text("You completed \(pattern.name) for \(durationSeconds / 60) minutes.")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                Text("Take a moment to notice how you feel.")
                    .font(BloomHerTheme.Typography.callout)
                    .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            BloomButton("Done", style: .primary, icon: BloomIcons.checkmark, isFullWidth: true) {
                onDismiss()
            }
            .padding(.horizontal, BloomHerTheme.Spacing.xl)
            .padding(.bottom, BloomHerTheme.Spacing.xxl)
        }
        .padding(BloomHerTheme.Spacing.lg)
        .background(BloomHerTheme.Colors.background)
        .onAppear {
            withAnimation(BloomHerTheme.Animation.gentle) {
                sparkleOpacity = 1
            }
        }
    }
}

// MARK: - Preview

#Preview("Breathing Exercise") {
    NavigationStack {
        BreathingExerciseView()
    }
    .environment(\.currentCyclePhase, .luteal)
}
