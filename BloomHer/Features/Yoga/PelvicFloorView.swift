//
//  PelvicFloorView.swift
//  BloomHer
//
//  Kegel / pelvic floor exercise session screen.
//  Guides the user through timed squeeze → hold → release → rest cycles
//  with an animated visual indicator, haptic cues on phase transitions,
//  rep counter, program selection, and educational content.
//

import SwiftUI

// MARK: - PelvicFloorView

struct PelvicFloorView: View {

    // MARK: - Program

    enum Program: String, CaseIterable, Identifiable {
        case quick    = "Quick (5 min)"
        case standard = "Standard (10 min)"
        case advanced = "Advanced (15 min)"

        var id: String { rawValue }

        var durationMinutes: Int {
            switch self {
            case .quick:    return 5
            case .standard: return 10
            case .advanced: return 15
            }
        }

        var totalReps: Int {
            switch self {
            case .quick:    return 8
            case .standard: return 15
            case .advanced: return 24
            }
        }

        var squeezeSeconds: Int { 4 }
        var holdSeconds:    Int {
            switch self {
            case .quick:    return 2
            case .standard: return 4
            case .advanced: return 6
            }
        }
        var releaseSeconds: Int { 4 }
        var restSeconds:    Int { 6 }

        var icon: String {
            switch self {
            case .quick:    return BloomIcons.figureStand
            case .standard: return BloomIcons.yoga
            case .advanced: return BloomIcons.flame
            }
        }

        var color: Color {
            switch self {
            case .quick:    return BloomHerTheme.Colors.sageGreen
            case .standard: return BloomHerTheme.Colors.accentLavender
            case .advanced: return BloomHerTheme.Colors.primaryRose
            }
        }
    }

    // MARK: - Phase

    enum ExercisePhase: String {
        case idle, squeeze, hold, release, rest, complete

        var label: String {
            switch self {
            case .idle:     return "Ready"
            case .squeeze:  return "Squeeze"
            case .hold:     return "Hold"
            case .release:  return "Release"
            case .rest:     return "Rest"
            case .complete: return "Complete"
            }
        }

        var icon: String {
            switch self {
            case .idle:     return BloomIcons.figureStand
            case .squeeze:  return BloomIcons.pulse
            case .hold:     return BloomIcons.pause
            case .release:  return BloomIcons.breathing
            case .rest:     return BloomIcons.moonStars
            case .complete: return BloomIcons.checkmarkCircle
            }
        }

        var indicatorScale: CGFloat {
            switch self {
            case .idle:     return 0.75
            case .squeeze:  return 1.0
            case .hold:     return 1.0
            case .release:  return 0.75
            case .rest:     return 0.60
            case .complete: return 0.90
            }
        }

        var color: Color {
            switch self {
            case .idle:     return BloomHerTheme.Colors.textTertiary
            case .squeeze:  return BloomHerTheme.Colors.primaryRose
            case .hold:     return BloomHerTheme.Colors.accentPeach
            case .release:  return BloomHerTheme.Colors.sageGreen
            case .rest:     return BloomHerTheme.Colors.accentLavender
            case .complete: return BloomHerTheme.Colors.success
            }
        }
    }

    // MARK: - State

    @State private var selectedProgram: Program = .standard
    @State private var currentPhase: ExercisePhase = .idle
    @State private var currentRep: Int = 0
    @State private var phaseSecondsRemaining: Int = 0
    @State private var isRunning: Bool = false
    @State private var isCompleted: Bool = false
    @State private var pulseAmount: CGFloat = 0.0
    @State private var timer: Timer? = nil
    @State private var showEducation: Bool = false

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xxl) {
                programSelector
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                indicatorSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                repProgress
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                controlButtons
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                educationCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.top, BloomHerTheme.Spacing.xl)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Pelvic Floor")
        .onDisappear { stopSession() }
        .sheet(isPresented: $showEducation) {
            PelvicFloorEducationSheet()
                .bloomSheet()
        }
        .overlay {
            if isCompleted {
                completionOverlay
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(BloomHerTheme.Animation.standard, value: isCompleted)
    }

    // MARK: - Program Selector

    private var programSelector: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Choose Program")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                ForEach(Program.allCases) { program in
                    programButton(program)
                }
            }
        }
        .disabled(isRunning)
        .staggeredAppear(index: 0)
    }

    private func programButton(_ program: Program) -> some View {
        let isSelected = selectedProgram == program
        return Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selectedProgram = program
                resetSession()
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(program.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(isSelected ? .white : program.color)
                Text(program.durationMinutes == 5 ? "Quick" :
                     program.durationMinutes == 10 ? "Standard" : "Advanced")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(isSelected ? .white : BloomHerTheme.Colors.textSecondary)
                Text("\(program.durationMinutes) min")
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.80) : BloomHerTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(isSelected ? program.color : BloomHerTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous))
            .bloomShadow(isSelected ? BloomHerTheme.Shadows.medium : BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: - Indicator Section

    private var indicatorSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            // Animated squeeze indicator
            ZStack {
                // Outer ambient ring
                Circle()
                    .fill(currentPhase.color.opacity(0.08))
                    .frame(width: 220, height: 220)

                // Pulsing outer ring
                Circle()
                    .stroke(
                        currentPhase.color.opacity(0.20),
                        lineWidth: 3
                    )
                    .frame(width: 200 + pulseAmount * 20, height: 200 + pulseAmount * 20)
                    .animation(BloomHerTheme.Animation.gentle, value: pulseAmount)

                // Main indicator circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentPhase.color.opacity(0.90),
                                currentPhase.color.opacity(0.55)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 90
                        )
                    )
                    .frame(
                        width: 160 * currentPhase.indicatorScale,
                        height: 160 * currentPhase.indicatorScale
                    )
                    .animation(phaseAnimation, value: currentPhase.indicatorScale)
                    .bloomShadow(BloomHerTheme.Shadows.phaseGlow(for: .menstrual))

                // Center content
                VStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Image(currentPhase.icon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundStyle(.white)
                        .animation(BloomHerTheme.Animation.quick, value: currentPhase.rawValue)

                    Text(currentPhase.label)
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .contentTransition(.opacity)
                        .animation(BloomHerTheme.Animation.quick, value: currentPhase.rawValue)

                    if isRunning && currentPhase != .complete {
                        Text("\(phaseSecondsRemaining)")
                            .font(BloomHerTheme.Typography.title2)
                            .foregroundStyle(.white.opacity(0.90))
                            .monospacedDigit()
                            .contentTransition(.numericText(countsDown: true))
                            .animation(BloomHerTheme.Animation.quick, value: phaseSecondsRemaining)
                    }
                }
            }

            // Phase label hints
            if isRunning {
                phaseHintRow
            }
        }
        .staggeredAppear(index: 1)
    }

    private var phaseHintRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            ForEach([
                ExercisePhase.squeeze,
                .hold,
                .release,
                .rest
            ], id: \.rawValue) { phase in
                VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                    Circle()
                        .fill(currentPhase == phase ? phase.color : Color.primary.opacity(0.12))
                        .frame(width: 8, height: 8)
                        .animation(BloomHerTheme.Animation.quick, value: currentPhase.rawValue)
                    Text(phase.label)
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(
                            currentPhase == phase
                            ? phase.color
                            : BloomHerTheme.Colors.textTertiary
                        )
                }
            }
        }
    }

    // MARK: - Rep Progress

    private var repProgress: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            HStack {
                Text("Reps")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Spacer()
                Text("\(currentRep) / \(selectedProgram.totalReps)")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .monospacedDigit()
            }

            BloomProgressBar(
                progress: Double(currentRep) / Double(selectedProgram.totalReps),
                color: selectedProgram.color,
                height: 10
            )

            // Rep dots for small programs
            if selectedProgram.totalReps <= 15 {
                repDots
            }
        }
        .staggeredAppear(index: 2)
    }

    private var repDots: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            ForEach(1...selectedProgram.totalReps, id: \.self) { rep in
                Circle()
                    .fill(rep <= currentRep
                          ? selectedProgram.color
                          : Color.primary.opacity(0.12))
                    .frame(width: 10, height: 10)
                    .animation(BloomHerTheme.Animation.quick.delay(Double(rep) * 0.02), value: currentRep)
            }
        }
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            if !isRunning && currentPhase == .idle {
                BloomButton(
                    "Start Session",
                    style: .primary,
                    size: .large,
                    icon: BloomIcons.play,
                    isFullWidth: true
                ) {
                    startSession()
                }
            } else if isRunning {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    BloomButton("Pause", style: .outline, size: .medium, icon: BloomIcons.pause) {
                        stopSession()
                    }
                    BloomButton("End", style: .danger, size: .medium, icon: BloomIcons.stopCircle) {
                        finishSession()
                    }
                }
            } else {
                BloomButton(
                    "Resume",
                    style: .secondary,
                    size: .large,
                    icon: BloomIcons.play,
                    isFullWidth: true
                ) {
                    resumeSession()
                }
            }
        }
        .staggeredAppear(index: 3)
    }

    // MARK: - Education Card

    private var educationCard: some View {
        BloomCard(isPhaseAware: false, elevation: .medium) {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(BloomHerTheme.Colors.accentLavender.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(BloomIcons.info)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("About Pelvic Floor Exercises")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Strengthen your core foundation. Tap to learn more.")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                Spacer()

                Image(BloomIcons.chevronRight)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .onTapGesture {
            BloomHerTheme.Haptics.light()
            showEducation = true
        }
        .buttonStyle(ScaleButtonStyle())
        .staggeredAppear(index: 4)
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        ZStack {
            BloomHerTheme.Colors.background
                .opacity(0.96)
                .ignoresSafeArea()

            VStack(spacing: BloomHerTheme.Spacing.xl) {
                KawaiiIllustrationView(illustration: .fullFlower, size: 120)

                VStack(spacing: BloomHerTheme.Spacing.sm) {
                    Text("Session Complete!")
                        .font(BloomHerTheme.Typography.title1)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("You completed \(selectedProgram.totalReps) reps — wonderful work!")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BloomHerTheme.Spacing.xl)
                }

                HeartParticleView(color: BloomHerTheme.Colors.primaryRose, count: 10)
                    .frame(width: 200, height: 120)
                    .allowsHitTesting(false)

                BloomButton("Done", style: .primary, size: .large, icon: BloomIcons.checkmark, isFullWidth: true) {
                    dismiss()
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
            }
        }
    }

    // MARK: - Session Logic

    private func startSession() {
        resetSession()
        isRunning = true
        currentRep = 0
        transitionToPhase(.squeeze)
    }

    private func resumeSession() {
        isRunning = true
        schedulePhaseTimer(duration: phaseSecondsRemaining)
    }

    private func stopSession() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func finishSession() {
        stopSession()
        withAnimation(BloomHerTheme.Animation.standard) {
            isCompleted = true
        }
    }

    private func resetSession() {
        stopSession()
        currentPhase = .idle
        currentRep = 0
        phaseSecondsRemaining = 0
        isCompleted = false
    }

    private func transitionToPhase(_ phase: ExercisePhase) {
        let duration: Int
        switch phase {
        case .squeeze: duration = selectedProgram.squeezeSeconds
        case .hold:    duration = selectedProgram.holdSeconds
        case .release: duration = selectedProgram.releaseSeconds
        case .rest:    duration = selectedProgram.restSeconds
        default:       duration = 0
        }

        BloomHerTheme.Haptics.medium()

        withAnimation(BloomHerTheme.Animation.standard) {
            currentPhase = phase
            phaseSecondsRemaining = duration
        }

        // Pulse on squeeze
        if phase == .squeeze || phase == .hold {
            withAnimation(BloomHerTheme.Animation.pulse) {
                pulseAmount = 1.0
            }
        } else {
            withAnimation(BloomHerTheme.Animation.standard) {
                pulseAmount = 0.0
            }
        }

        schedulePhaseTimer(duration: duration)
    }

    private func schedulePhaseTimer(duration: Int) {
        timer?.invalidate()
        phaseSecondsRemaining = duration
        var elapsed = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            elapsed += 1
            withAnimation(BloomHerTheme.Animation.quick) {
                phaseSecondsRemaining = max(0, duration - elapsed)
            }

            if elapsed >= duration {
                t.invalidate()
                advancePhase()
            }
        }
        if let t = timer {
            RunLoop.main.add(t, forMode: .common)
        }
    }

    private func advancePhase() {
        switch currentPhase {
        case .squeeze:
            transitionToPhase(.hold)
        case .hold:
            transitionToPhase(.release)
        case .release:
            transitionToPhase(.rest)
        case .rest:
            let nextRep = currentRep + 1
            withAnimation(BloomHerTheme.Animation.quick) {
                currentRep = nextRep
            }
            if nextRep >= selectedProgram.totalReps {
                finishSession()
            } else {
                transitionToPhase(.squeeze)
            }
        default:
            break
        }
    }

    // MARK: - Phase Animation

    private var phaseAnimation: Animation {
        switch currentPhase {
        case .squeeze:
            return .easeInOut(duration: Double(selectedProgram.squeezeSeconds))
        case .release:
            return .easeInOut(duration: Double(selectedProgram.releaseSeconds))
        default:
            return BloomHerTheme.Animation.standard
        }
    }
}

// MARK: - PelvicFloorEducationSheet

private struct PelvicFloorEducationSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    // Illustration
                    KawaiiIllustrationView(illustration: .yogaMat, size: 100)
                        .frame(maxWidth: .infinity)
                        .padding(.top, BloomHerTheme.Spacing.lg)

                    Group {
                        educationSection(
                            title: "What is the Pelvic Floor?",
                            body: "The pelvic floor is a group of muscles that span the base of the pelvis. They support the bladder, bowel, and uterus, and play a vital role in bladder and bowel control, sexual function, and core stability.",
                            icon: BloomIcons.yoga
                        )
                        educationSection(
                            title: "Benefits of Regular Kegel Exercises",
                            body: "• Reduces urinary incontinence\n• Supports recovery after childbirth\n• Improves pelvic organ support\n• Enhances sexual sensation\n• Prevents prolapse\n• Builds core stability",
                            icon: BloomIcons.sparkles
                        )
                        educationSection(
                            title: "How to Perform a Kegel",
                            body: "Imagine you are trying to stop the flow of urine. Squeeze and lift the pelvic floor muscles upward. Avoid holding your breath or tightening your buttocks, thighs, or abdomen. The movement should be internal and subtle.",
                            icon: BloomIcons.info
                        )
                        educationSection(
                            title: "When to be Cautious",
                            body: "If you experience pain, pressure, or worsening symptoms, stop and consult your healthcare provider. Hypertonic pelvic floor conditions require a different approach — a pelvic health physiotherapist can help.",
                            icon: BloomIcons.heartFilled
                        )
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Pelvic Floor Guide")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(BloomIcons.xmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
        }
    }

    private func educationSection(title: String, body: String, icon: String) -> some View {
        BloomCard {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text(title)
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(body)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview("Pelvic Floor — Idle") {
    NavigationStack {
        PelvicFloorView()
    }
}

#Preview("Pelvic Floor Education") {
    PelvicFloorEducationSheet()
}
