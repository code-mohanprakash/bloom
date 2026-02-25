//
//  KickCounterView.swift
//  BloomHer
//
//  Full-screen kick counting interface with a large circular tap target,
//  heart particle animation, live pacing feedback, and a 2-hour time
//  window indicator.
//
//  Medical basis
//  -------------
//  One widely-used guideline (ACOG) is 10 movements in 2 hours, typically
//  recommended from 28 weeks. Thresholds vary by provider and country.
//  The app tracks movement counts and elapsed time, giving pacing context,
//  but never replaces healthcare-provider guidance.
//

import SwiftUI

// MARK: - Pace Status

private enum PaceStatus {
    /// Session not yet started.
    case waiting
    /// Session active, baby moving at or above the expected pace.
    case onTrack
    /// Session active, baby moving below expected pace for elapsed time.
    case slowPace
    /// Goal reached — 10 movements recorded.
    case goalReached
    /// 2-hour window elapsed without reaching the goal.
    case overWindow

    var label: String {
        switch self {
        case .waiting:     return "Tap the circle each time your baby moves"
        case .onTrack:     return "On track — keep going"
        case .slowPace:    return "Keep counting — movement patterns vary"
        case .goalReached: return "Goal reached"
        case .overWindow:  return "See guidance below"
        }
    }

    var color: Color {
        switch self {
        case .waiting:     return BloomHerTheme.Colors.textTertiary
        case .onTrack:     return BloomHerTheme.Colors.sageGreen
        case .slowPace:    return BloomHerTheme.Colors.accentPeach
        case .goalReached: return BloomHerTheme.Colors.sageGreen
        case .overWindow:  return BloomHerTheme.Colors.accentPeach
        }
    }

    var icon: String {
        switch self {
        case .waiting:     return BloomIcons.handTap
        case .onTrack:     return BloomIcons.checkmarkCircle
        case .slowPace:    return BloomIcons.clock
        case .goalReached: return BloomIcons.sparkles
        case .overWindow:  return BloomIcons.info
        }
    }
}

// MARK: - KickCounterView

struct KickCounterView: View {

    // MARK: State

    @State private var viewModel: PregnancyViewModel
    @State private var isSessionActive: Bool = false
    @State private var kickCount: Int = 0
    @State private var sessionStart: Date?
    @State private var elapsedSeconds: Int = 0
    @State private var showHearts: Bool = false
    @State private var heartTrigger: Int = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var currentSession: KickSession?
    @State private var timer: Timer?
    @State private var rippleActive: Bool = false

    // MARK: Constants

    private let kickGoal = 10
    /// Two-hour window in seconds (ACOG guideline).
    private let windowSeconds: Double = 7_200

    // MARK: Init

    init(viewModel: PregnancyViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: Computed — progress

    private var goalProgress: Double {
        min(Double(kickCount) / Double(kickGoal), 1.0)
    }

    /// How far through the 2-hour window we are (0–1, capped at 1).
    private var windowProgress: Double {
        guard isSessionActive else { return 0 }
        return min(Double(elapsedSeconds) / windowSeconds, 1.0)
    }

    /// Expected kicks at the current pace to hit 10 in exactly 2 hours.
    private var expectedKicksByNow: Double {
        guard isSessionActive, elapsedSeconds > 0 else { return 0 }
        return Double(kickGoal) * (Double(elapsedSeconds) / windowSeconds)
    }

    private var paceStatus: PaceStatus {
        guard isSessionActive else { return .waiting }
        if kickCount >= kickGoal { return .goalReached }
        if Double(elapsedSeconds) >= windowSeconds { return .overWindow }
        // Give a generous first-5-minute grace period before showing slow pace
        if elapsedSeconds < 300 { return .onTrack }
        return Double(kickCount) >= expectedKicksByNow ? .onTrack : .slowPace
    }

    private var goalReached: Bool { kickCount >= kickGoal }

    /// Minutes remaining in the 2-hour window (clamped to 0).
    private var minutesRemaining: Int {
        max(0, (Int(windowSeconds) - elapsedSeconds) / 60)
    }

    private var elapsedFormatted: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var tapColor: Color {
        if goalReached { return BloomHerTheme.Colors.sageGreen }
        if paceStatus == .slowPace { return BloomHerTheme.Colors.accentPeach }
        if kickCount > 5 { return BloomHerTheme.Colors.accentLavender }
        return BloomHerTheme.Colors.primaryRose
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                sessionStatusRow
                tapArea
                progressCard
                if paceStatus == .overWindow {
                    overWindowGuidanceCard
                }
                controlButtons
                sessionHistorySection
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Kick Counter")
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Session Status Row

    private var sessionStatusRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(isSessionActive ? "Session Active" : "Ready to Count")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                if isSessionActive {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Circle()
                            .fill(BloomHerTheme.Colors.sageGreen)
                            .frame(width: 8, height: 8)
                            .scaleEffect(rippleActive ? 1.3 : 1.0)
                            .animation(BloomHerTheme.Animation.pulse, value: rippleActive)
                        Text(elapsedFormatted)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .monospacedDigit()
                    }
                }
            }
            Spacer()
            Text("Today: \(viewModel.todaysKickCount)")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Tap Area

    private var tapArea: some View {
        ZStack {
            // 2-hour window arc (underneath everything)
            if isSessionActive && !goalReached {
                Circle()
                    .trim(from: 0, to: windowProgress)
                    .stroke(
                        paceStatus == .overWindow
                            ? BloomHerTheme.Colors.accentPeach.opacity(0.5)
                            : BloomHerTheme.Colors.accentLavender.opacity(0.4),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 308, height: 308)
                    .rotationEffect(.degrees(-90))
                    .animation(BloomHerTheme.Animation.standard, value: windowProgress)
            }

            // Outer pulse ring
            Circle()
                .strokeBorder(tapColor.opacity(0.15), lineWidth: 20)
                .frame(width: 300, height: 300)
                .scaleEffect(pulseScale)
                .animation(
                    isSessionActive ? BloomHerTheme.Animation.breath : .default,
                    value: pulseScale
                )

            // Middle ring
            Circle()
                .strokeBorder(tapColor.opacity(0.25), lineWidth: 8)
                .frame(width: 260, height: 260)

            // Main tap circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tapColor.opacity(0.9), tapColor.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .bloomShadow(BloomHerTheme.Shadows.glow)

            // Kick count + label
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Text("\(kickCount)")
                    .font(BloomHerTheme.Typography.cycleDay)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(BloomHerTheme.Animation.quick, value: kickCount)

                Text(isSessionActive ? "Tap to count movement" : "Tap to start")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                if goalReached {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.checkmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text("Goal reached!")
                    }
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            // Heart particles
            if showHearts {
                HeartParticleView(color: .white, count: 6, duration: 1.5)
                    .frame(width: 280, height: 280)
                    .allowsHitTesting(false)
                    .id(heartTrigger)
            }
        }
        .frame(width: 320, height: 320)
        .onTapGesture { handleTap() }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityHint("Tap each time you feel your baby move")
        .animation(BloomHerTheme.Animation.quick, value: kickCount)
        .animation(BloomHerTheme.Animation.standard, value: goalReached)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {

                // ── Kick count row ───────────────────────────────────────────
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    HStack {
                        Image(BloomIcons.handTap)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(goalReached
                                ? BloomHerTheme.Colors.sageGreen
                                : BloomHerTheme.Colors.primaryRose)
                        Text("Movements")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Spacer()
                        Text("\(kickCount) / \(kickGoal)")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .monospacedDigit()
                    }
                    BloomProgressBar(
                        progress: goalProgress,
                        color: goalReached
                            ? BloomHerTheme.Colors.sageGreen
                            : BloomHerTheme.Colors.primaryRose,
                        height: 8
                    )
                }

                // ── Time window row (only during active session) ─────────────
                if isSessionActive && !goalReached {
                    Divider()

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        HStack {
                            Image(BloomIcons.clock)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(paceStatus == .overWindow
                                    ? BloomHerTheme.Colors.accentPeach
                                    : BloomHerTheme.Colors.accentLavender)
                            Text("2-hour window")
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            Spacer()
                            Text(paceStatus == .overWindow
                                 ? "Ended"
                                 : "\(minutesRemaining) min left")
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                .monospacedDigit()
                                .animation(.none, value: minutesRemaining)
                        }
                        BloomProgressBar(
                            progress: windowProgress,
                            color: paceStatus == .overWindow
                                ? BloomHerTheme.Colors.accentPeach
                                : BloomHerTheme.Colors.accentLavender,
                            height: 8
                        )
                    }
                }

                // ── Pace status pill ─────────────────────────────────────────
                if isSessionActive {
                    Divider()

                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(paceStatus.icon)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(paceStatus.color)
                        Text(paceStatus.label)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(paceStatus.color)
                        Spacer()
                    }
                    .animation(BloomHerTheme.Animation.quick, value: paceStatus.label)
                }

                // ── Static guideline note ────────────────────────────────────
                Divider()

                Text("Count any movement — kicks, rolls, swishes, or punches. Thresholds vary by provider; 10 movements in 2 hours is one common guideline (recommended from ~28 weeks). Always follow your healthcare provider's specific advice.")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .animation(BloomHerTheme.Animation.standard, value: isSessionActive)
    }

    // MARK: - Over-Window Guidance Card

    /// Shown only when the 2-hour window has elapsed and the goal was not reached.
    /// Provides evidence-based next steps without alarming the user.
    private var overWindowGuidanceCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.info)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("What to do next")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    guidanceRow(
                        number: "1",
                        text: "Have a cold drink or a light snack, then lie on your left side and count again for another hour."
                    )
                    guidanceRow(
                        number: "2",
                        text: "If you still don't feel reassured by your baby's movements, call your midwife or maternity unit — they will not mind being contacted."
                    )
                    guidanceRow(
                        number: "3",
                        text: "Do not use this app to decide whether your baby is safe. Only a healthcare provider can assess fetal wellbeing."
                    )
                }

                Text("Reduced fetal movement can sometimes require assessment. If you are worried at any point, trust your instinct and seek care immediately.")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, BloomHerTheme.Spacing.xxxs)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func guidanceRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.accentPeach.opacity(0.15))
                    .frame(width: 22, height: 22)
                Text(number)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.accentPeach)
            }
            Text(text)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            if isSessionActive {
                BloomButton("Undo", style: .outline, icon: BloomIcons.refresh) {
                    undoKick()
                }

                BloomButton("End Session", style: .secondary, icon: BloomIcons.stopCircle, isFullWidth: true) {
                    endSession()
                }
            } else {
                BloomButton(
                    kickCount > 0 ? "Start New Session" : "Start Session",
                    style: .primary,
                    icon: BloomIcons.play,
                    isFullWidth: true
                ) {
                    startSession()
                }
            }
        }
    }

    // MARK: - Session History

    private var sessionHistorySection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Recent Sessions")

            if viewModel.recentKickSessions.isEmpty {
                BloomCard {
                    HStack {
                        Image(BloomIcons.handTap)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        Text("No sessions recorded yet")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: BloomHerTheme.Spacing.sm) {
                    ForEach(viewModel.recentKickSessions) { session in
                        KickSessionRow(session: session)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func handleTap() {
        if !isSessionActive {
            startSession()
            return
        }
        // Don't count past the goal — but still allow tapping so user isn't confused
        kickCount += 1
        currentSession?.kickCount = kickCount
        BloomHerTheme.Haptics.medium()

        heartTrigger += 1
        showHearts = true

        withAnimation(BloomHerTheme.Animation.quick) { pulseScale = 1.08 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(BloomHerTheme.Animation.gentle) { pulseScale = 1.0 }
        }

        if goalReached { BloomHerTheme.Haptics.success() }
    }

    private func startSession() {
        let session = KickSession(pregnancy: viewModel.pregnancyProfile)
        currentSession = session
        kickCount = 0
        sessionStart = Date()
        elapsedSeconds = 0
        isSessionActive = true
        rippleActive = true

        withAnimation(BloomHerTheme.Animation.standard) { pulseScale = 1.0 }
        startTimer()
        BloomHerTheme.Haptics.medium()
    }

    private func endSession() {
        guard let session = currentSession else { return }
        session.endTime = Date()
        session.kickCount = kickCount
        viewModel.saveKickSession(session)

        stopTimer()
        withAnimation(BloomHerTheme.Animation.standard) {
            isSessionActive = false
            rippleActive = false
        }
        currentSession = nil
        BloomHerTheme.Haptics.success()
    }

    private func undoKick() {
        guard kickCount > 0 else { return }
        kickCount -= 1
        currentSession?.kickCount = kickCount
        BloomHerTheme.Haptics.light()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - KickSessionRow

private struct KickSessionRow: View {
    let session: KickSession

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: session.startTime)
    }

    var body: some View {
        BloomCard {
            HStack {
                Image(BloomIcons.handTap)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("\(session.kickCount) movements")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(dateFormatted)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("\(session.durationMinutes) min")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    if session.kickCount >= 10 {
                        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                            Image(BloomIcons.checkmarkCircle)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                            Text("Goal met")
                                .font(BloomHerTheme.Typography.caption)
                        }
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Kick Counter") {
    NavigationStack {
        KickCounterView(viewModel: PregnancyViewModel(repository: PreviewKickRepo()))
    }
}

private class PreviewKickRepo: PregnancyRepositoryProtocol {
    func fetchActivePregnancy() -> PregnancyProfile? { nil }
    func fetchAllPregnancies() -> [PregnancyProfile] { [] }
    func savePregnancy(_ pregnancy: PregnancyProfile) {}
    func deletePregnancy(_ pregnancy: PregnancyProfile) {}
    func fetchKickSessions(for pregnancy: PregnancyProfile) -> [KickSession] { [] }
    func saveKickSession(_ session: KickSession) {}
    func fetchContractions(for pregnancy: PregnancyProfile) -> [ContractionEntry] { [] }
    func saveContraction(_ contraction: ContractionEntry) {}
    func fetchWeightEntries(for pregnancy: PregnancyProfile) -> [WeightEntry] { [] }
    func saveWeightEntry(_ entry: WeightEntry) {}
    func fetchAppointments(for pregnancy: PregnancyProfile) -> [Appointment] { [] }
    func saveAppointment(_ appointment: Appointment) {}
    func deleteAppointment(_ appointment: Appointment) {}
}
