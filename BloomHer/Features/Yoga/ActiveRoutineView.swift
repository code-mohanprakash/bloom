//
//  ActiveRoutineView.swift
//  BloomHer
//
//  Full-screen routine player. Manages per-pose countdown timers, overall
//  progress, pause/resume/skip/end controls, slide transitions between poses,
//  audio cues, and session recording on completion.
//

import SwiftUI
import AVFoundation

// MARK: - ActiveRoutineView

struct ActiveRoutineView: View {

    // MARK: - Configuration

    let routine: YogaRoutine
    var viewModel: YogaViewModel

    // MARK: - State

    @State private var currentPoseIndex: Int = 0
    @State private var secondsRemaining: Int = 0
    @State private var isPaused: Bool = false
    @State private var isCompleted: Bool = false
    @State private var slideDirection: SlideDirection = .forward
    @State private var showCelebration: Bool = false
    @State private var elapsedMinutes: Int = 0
    @State private var timer: Timer? = nil
    @State private var sessionStartTime: Date = Date()
    @State private var resolvedPoses: [(pose: YogaPose, ref: YogaPoseReference)] = []

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currentCyclePhase) private var phase

    // MARK: - Computed

    private var currentPose: YogaPose? { resolvedPoses[safe: currentPoseIndex]?.pose }
    private var currentRef: YogaPoseReference? { resolvedPoses[safe: currentPoseIndex]?.ref }
    private var nextPose: YogaPose? { resolvedPoses[safe: currentPoseIndex + 1]?.pose }
    private var totalPoses: Int { resolvedPoses.count }
    private var overallProgress: Double {
        guard totalPoses > 0 else { return 0 }
        return Double(currentPoseIndex) / Double(totalPoses)
    }
    private var phaseColor: Color { BloomHerTheme.Colors.phase(phase) }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Full-screen background
            BloomColors.phaseBackground(for: phase)
                .ignoresSafeArea()
            BloomHerTheme.Colors.background
                .ignoresSafeArea()
                .opacity(0.85)

            if isCompleted {
                completionView
                    .transition(.opacity.combined(with: .scale))
            } else if let pose = currentPose, let ref = currentRef {
                mainPlayerView(pose: pose, ref: ref)
                    .transition(slideTransition)
            } else {
                loadingView
            }

            // Celebration particle overlay
            if showCelebration {
                celebrationOverlay
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            setupPoses()
            sessionStartTime = Date()
            startCurrentPose()
        }
        .onDisappear {
            stopTimer()
        }
        .animation(BloomHerTheme.Animation.standard, value: isCompleted)
        .animation(BloomHerTheme.Animation.standard, value: currentPoseIndex)
    }

    // MARK: - Main Player View

    private func mainPlayerView(pose: YogaPose, ref: YogaPoseReference) -> some View {
        VStack(spacing: 0) {
            // Top bar
            topBar

            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.xl) {
                    // Progress indicator
                    overallProgressRow

                    // Pose illustration + timer
                    timerAndPoseSection(pose: pose, ref: ref)

                    // Instructions
                    instructionsSection(pose: pose)

                    // Next pose preview
                    if let next = nextPose {
                        nextPosePreview(pose: next)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.massive)
            }

            // Control bar
            controlBar
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                BloomHerTheme.Haptics.light()
                stopTimer()
                dismiss()
            } label: {
                Image(BloomIcons.xmarkCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                Text(routine.name)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Pose \(currentPoseIndex + 1) of \(totalPoses)")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }

            Spacer()

            // Elapsed time
            Text(elapsedTimeLabel)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                .monospacedDigit()
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .padding(.vertical, BloomHerTheme.Spacing.sm)
        .background(.ultraThinMaterial)
    }

    // MARK: - Overall Progress

    private var overallProgressRow: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            HStack {
                Text("Overall Progress")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                Spacer()
                Text("\(currentPoseIndex + 1)/\(totalPoses)")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            BloomProgressBar(
                progress: overallProgress,
                color: phaseColor,
                height: 8
            )
        }
        .staggeredAppear(index: 0)
    }

    // MARK: - Timer & Pose Section

    private func timerAndPoseSection(pose: YogaPose, ref: YogaPoseReference) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            // Large icon above ring
            ZStack {
                Circle()
                    .fill(phaseColor.opacity(0.12))
                    .frame(width: 90, height: 90)
                Image(BloomIcons.yoga)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
            }
            .scaleEffect(isPaused ? 0.94 : 1.0)
            .animation(BloomHerTheme.Animation.pulse, value: isPaused)

            // Circular timer ring
            RoutineTimerRing(
                remainingSeconds: secondsRemaining,
                totalSeconds: ref.holdDurationSeconds,
                phaseColor: phaseColor,
                ringSize: .large,
                isRunning: !isPaused
            )

            // Pose name
            VStack(spacing: BloomHerTheme.Spacing.xxs) {
                Text(pose.name)
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                    .animation(BloomHerTheme.Animation.quick, value: currentPoseIndex)

                if let sanskrit = pose.sanskritName {
                    Text(sanskrit)
                        .font(BloomHerTheme.Typography.callout)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .italic()
                        .contentTransition(.opacity)
                }

                if let reps = ref.repetitions {
                    Text("\(reps) repetitions")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(phaseColor)
                        .padding(.horizontal, BloomHerTheme.Spacing.sm)
                        .padding(.vertical, BloomHerTheme.Spacing.xxs)
                        .background(phaseColor.opacity(0.12), in: Capsule())
                }
            }
        }
        .staggeredAppear(index: 1)
    }

    // MARK: - Instructions Section

    private func instructionsSection(pose: YogaPose) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Instructions")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                ForEach(Array(pose.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(phaseColor.opacity(0.15))
                                .frame(width: 26, height: 26)
                            Text("\(index + 1)")
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(phaseColor)
                        }
                        Text(step)
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if let note = resolvedPoses[safe: currentPoseIndex]?.pose.safetyMatrix.notes,
               viewModel.isPregnant {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.heartFilled)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(note)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                .padding(BloomHerTheme.Spacing.sm)
                .background(BloomHerTheme.Colors.primaryRose.opacity(0.08), in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .bloomShadow(BloomHerTheme.Shadows.small)
        .staggeredAppear(index: 2)
    }

    // MARK: - Next Pose Preview

    private func nextPosePreview(pose: YogaPose) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("Up next")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .textCase(.uppercase)
                Text(pose.name)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                if let sanskrit = pose.sanskritName {
                    Text(sanskrit)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .italic()
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(phaseColor.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(BloomIcons.yoga)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.surface.opacity(0.80))
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .staggeredAppear(index: 3)
    }

    // MARK: - Control Bar

    private var controlBar: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxl) {
            // End routine
            Button {
                BloomHerTheme.Haptics.medium()
                stopTimer()
                saveSession()
                withAnimation(BloomHerTheme.Animation.standard) {
                    isCompleted = true
                    showCelebration = true
                }
            } label: {
                VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                    Image(BloomIcons.stopCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(BloomHerTheme.Colors.error)
                    Text("End")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // Pause/Resume
            Button {
                BloomHerTheme.Haptics.medium()
                isPaused.toggle()
                if isPaused {
                    stopTimer()
                } else {
                    resumeTimer()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(phaseColor)
                        .frame(width: 72, height: 72)
                    Image(isPaused ? BloomIcons.play : BloomIcons.pause)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .bloomShadow(BloomHerTheme.Shadows.phaseGlow(for: phase))

            // Skip pose
            Button {
                BloomHerTheme.Haptics.light()
                skipToNextPose()
            } label: {
                VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                    Image(BloomIcons.forwardEnd)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Text("Skip")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(currentPoseIndex >= totalPoses - 1)
            .opacity(currentPoseIndex >= totalPoses - 1 ? 0.40 : 1.0)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.xl)
        .padding(.vertical, BloomHerTheme.Spacing.lg)
        .background(.ultraThinMaterial)
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Spacer()

            // Celebration illustration
            ZStack {
                Circle()
                    .fill(phaseColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                KawaiiIllustrationView(illustration: .fullFlower, size: 110)
            }

            VStack(spacing: BloomHerTheme.Spacing.sm) {
                Text("Wonderful practice!")
                    .font(BloomHerTheme.Typography.title1)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text("You completed \(routine.name)")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Stats summary
            HStack(spacing: BloomHerTheme.Spacing.xxl) {
                completionStat(value: "\(elapsedMinutes)", unit: "minutes", icon: BloomIcons.clock)
                completionStat(value: "\(totalPoses)", unit: "poses", icon: BloomIcons.yoga)
            }
            .padding(BloomHerTheme.Spacing.lg)
            .background(BloomHerTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .bloomShadow(BloomHerTheme.Shadows.medium)
            .padding(.horizontal, BloomHerTheme.Spacing.xl)

            Spacer()

            BloomButton(
                "Done",
                style: .primary,
                size: .large,
                icon: "checkmark",
                isFullWidth: true
            ) {
                dismiss()
            }
            .padding(.horizontal, BloomHerTheme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BloomHerTheme.Colors.background)
    }

    private func completionStat(value: String, unit: String, icon: String) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxs) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
            Text(value)
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .monospacedDigit()
            Text(unit)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Celebration Overlay

    private var celebrationOverlay: some View {
        ZStack {
            SparkleParticleView(color: phaseColor, count: 18)
            HeartParticleView(color: BloomHerTheme.Colors.primaryRose, count: 8)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            ProgressView()
                .tint(phaseColor)
            Text("Blooming…")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Timer Logic

    private func setupPoses() {
        resolvedPoses = routine.poses.compactMap { ref -> (pose: YogaPose, ref: YogaPoseReference)? in
            guard let pose = YogaPoseLibrary.pose(forId: ref.poseId) else { return nil }
            return (pose: pose, ref: ref)
        }
    }

    private func startCurrentPose() {
        guard let ref = resolvedPoses[safe: currentPoseIndex]?.ref else { return }
        secondsRemaining = ref.holdDurationSeconds
        isPaused = false
        playAudioCue(.start)
        scheduleTimer()
        trackElapsedTime()
    }

    private func scheduleTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !isPaused else { return }
            if secondsRemaining > 0 {
                withAnimation(BloomHerTheme.Animation.quick) {
                    secondsRemaining -= 1
                }
                if secondsRemaining == 3 {
                    BloomHerTheme.Haptics.light()
                }
            } else {
                advancePose()
            }
        }
        if let t = timer {
            RunLoop.main.add(t, forMode: .common)
        }
    }

    private func trackElapsedTime() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            elapsedMinutes += 1
        }
    }

    private func resumeTimer() {
        scheduleTimer()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func advancePose() {
        BloomHerTheme.Haptics.success()
        playAudioCue(.transition)

        let nextIndex = currentPoseIndex + 1
        if nextIndex >= totalPoses {
            // Routine complete
            stopTimer()
            saveSession()
            withAnimation(BloomHerTheme.Animation.standard) {
                isCompleted = true
                showCelebration = true
            }
        } else {
            slideDirection = .forward
            withAnimation(BloomHerTheme.Animation.standard) {
                currentPoseIndex = nextIndex
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                startCurrentPose()
            }
        }
    }

    private func skipToNextPose() {
        guard currentPoseIndex < totalPoses - 1 else { return }
        stopTimer()
        slideDirection = .forward
        withAnimation(BloomHerTheme.Animation.standard) {
            currentPoseIndex += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            startCurrentPose()
        }
    }

    // MARK: - Session Saving

    private func saveSession() {
        let duration = max(1, elapsedMinutes > 0 ? elapsedMinutes : routine.durationMinutes)
        let session = YogaSession(
            routineId: routine.id,
            routineName: routine.name,
            category: routine.category,
            durationMinutes: duration
        )
        session.completed = isCompleted || currentPoseIndex >= totalPoses - 1
        viewModel.saveSession(session)
    }

    // MARK: - Audio Cues

    private enum AudioCueType { case start, transition }

    private func playAudioCue(_ type: AudioCueType) {
        let soundID: SystemSoundID
        switch type {
        case .start:      soundID = 1057   // Tink
        case .transition: soundID = 1054   // Camera
        }
        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Slide Transition

    private enum SlideDirection { case forward, backward }

    private var slideTransition: AnyTransition {
        switch slideDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    // MARK: - Elapsed Time Label

    private var elapsedTimeLabel: String {
        let elapsed = Int(Date().timeIntervalSince(sessionStartTime))
        let m = elapsed / 60
        let s = elapsed % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview("Active Routine") {
    let deps = AppDependencies.preview()
    let vm = YogaViewModel(yogaRepository: deps.yogaRepository)
    let _ = { vm.loadData() }()
    if let routine = vm.allRoutines.first {
        return AnyView(ActiveRoutineView(routine: routine, viewModel: vm)
            .environment(\.currentCyclePhase, .follicular))
    }
    return AnyView(Text("No routines available"))
}
