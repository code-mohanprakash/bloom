//
//  RoutineDetailView.swift
//  BloomHer
//
//  Detailed view of a single yoga routine before starting it.
//  Shows hero header, stats, description, pose list, safety warnings,
//  and a prominent "Start Routine" CTA at the bottom.
//

import SwiftUI

// MARK: - RoutineDetailView

struct RoutineDetailView: View {

    // MARK: - Configuration

    let routine: YogaRoutine
    var viewModel: YogaViewModel

    // MARK: - State

    @State private var showActiveRoutine: Bool = false
    @State private var resolvedPoses: [YogaPose] = []

    // MARK: - Environment

    @Environment(\.currentCyclePhase) private var phase

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                heroSection
                statsRow
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                descriptionSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                if !routine.safetyNotes.isEmpty {
                    safetyWarningsSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }

                poseListSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                if !routine.contraindications.isEmpty {
                    contraindicationsSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }

                startButton
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation(routine.name)
        .onAppear {
            resolvedPoses = routine.poses.compactMap { ref in
                YogaPoseLibrary.pose(forId: ref.poseId)
            }
        }
        .fullScreenCover(isPresented: $showActiveRoutine) {
            ActiveRoutineView(routine: routine, viewModel: viewModel)
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Gradient background
            LinearGradient(
                colors: [
                    BloomHerTheme.Colors.phase(viewModel.currentPhase).opacity(0.20),
                    BloomHerTheme.Colors.phase(viewModel.currentPhase).opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .ignoresSafeArea(edges: .top)

            VStack(spacing: BloomHerTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(BloomHerTheme.Colors.phase(viewModel.currentPhase).opacity(0.20))
                        .frame(width: 80, height: 80)
                    Image(BloomIcons.yoga)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                }

                VStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Text(routine.name)
                        .font(BloomHerTheme.Typography.title2)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    BloomChip(
                        routine.category.displayName,
                        color: BloomHerTheme.Colors.phase(viewModel.currentPhase),
                        isSelected: true,
                        action: {}
                    )
                }
            }
            .padding(.bottom, BloomHerTheme.Spacing.lg)
        }
        .staggeredAppear(index: 0)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            statItem(
                value: "\(routine.durationMinutes)",
                unit: "min",
                icon: BloomIcons.clock,
                color: BloomHerTheme.Colors.primaryRose
            )
            Divider().frame(height: 36)
            statItem(
                value: "\(routine.poseCount)",
                unit: "poses",
                icon: BloomIcons.yoga,
                color: BloomHerTheme.Colors.sageGreen
            )
            Divider().frame(height: 36)
            statItem(
                value: routine.difficulty.displayName,
                unit: "level",
                icon: BloomIcons.target,
                color: difficultyColor
            )
            Divider().frame(height: 36)
            statItem(
                value: "\(estimatedCalories)",
                unit: "kcal",
                icon: BloomIcons.flame,
                color: BloomHerTheme.Colors.accentPeach
            )
        }
        .padding(BloomHerTheme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(BloomHerTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .bloomShadow(BloomHerTheme.Shadows.medium)
        .staggeredAppear(index: 1)
    }

    private func statItem(value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text(value)
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .monospacedDigit()
            Text(unit)
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            sectionLabel("About this routine")
            Text(routine.description)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .staggeredAppear(index: 2)
    }

    // MARK: - Safety Warnings

    private var safetyWarningsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            sectionLabel("Safety Notes")

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                ForEach(routine.safetyNotes, id: \.self) { note in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Image(BloomIcons.info)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(BloomHerTheme.Colors.info)
                        Text(note)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.info.opacity(0.08), in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
        }
        .staggeredAppear(index: 3)
    }

    // MARK: - Pose List

    private var poseListSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            sectionLabel("Pose Sequence")

            if resolvedPoses.isEmpty {
                Text("Blooming…")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            } else {
                ForEach(Array(zip(resolvedPoses, routine.poses).enumerated()), id: \.offset) { index, pair in
                    let (pose, ref) = pair
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        // Sequence number
                        ZStack {
                            Circle()
                                .fill(BloomHerTheme.Colors.primaryRose.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Text("\(index + 1)")
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                        }

                        PoseCardView(
                            pose: pose,
                            isPregnant: viewModel.isPregnant,
                            trimester: viewModel.currentTrimester,
                            holdDuration: ref.holdDurationSeconds
                        )
                    }
                    .staggeredAppear(index: index + 4)
                }
            }
        }
    }

    // MARK: - Contraindications

    private var contraindicationsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            sectionLabel("Not suitable if you have")

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                ForEach(routine.contraindications, id: \.self) { item in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Image(BloomIcons.xmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(BloomHerTheme.Colors.error)
                        Text(item)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.error.opacity(0.08), in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
        }
        .staggeredAppear(index: 8)
    }

    // MARK: - Start Button

    private var startButton: some View {
        BloomButton(
            "Start Routine",
            style: .primary,
            size: .large,
            icon: BloomIcons.play,
            isFullWidth: true
        ) {
            showActiveRoutine = true
        }
        .staggeredAppear(index: 10)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(BloomHerTheme.Typography.headline)
            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
    }

    private var difficultyColor: Color {
        switch routine.difficulty {
        case .beginner:     return BloomHerTheme.Colors.sageGreen
        case .intermediate: return BloomHerTheme.Colors.accentPeach
        case .advanced:     return BloomHerTheme.Colors.primaryRose
        }
    }

    /// Rough calories burned estimate based on duration and difficulty.
    private var estimatedCalories: Int {
        let base = Double(routine.durationMinutes)
        let multiplier: Double
        switch routine.difficulty {
        case .beginner:     multiplier = 2.5
        case .intermediate: multiplier = 3.5
        case .advanced:     multiplier = 5.0
        }
        return Int(base * multiplier)
    }
}

// MARK: - Preview

#Preview("Routine Detail") {
    NavigationStack {
        let deps = AppDependencies.preview()
        let vm = YogaViewModel(yogaRepository: deps.yogaRepository)
        let _ = { vm.loadData() }()
        if let routine = vm.allRoutines.first {
            return AnyView(RoutineDetailView(routine: routine, viewModel: vm)
                .environment(\.currentCyclePhase, .follicular))
        }
        return AnyView(Text("No routines"))
    }
}
