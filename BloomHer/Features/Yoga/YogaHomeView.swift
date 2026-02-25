//
//  YogaHomeView.swift
//  BloomHer
//
//  Main yoga & movement tab screen. Displays phase-recommended routines,
//  a pregnancy safety banner, category browse grid, recent sessions,
//  and quick-action shortcuts.
//

import SwiftUI

// MARK: - YogaHomeView

struct YogaHomeView: View {

    // MARK: - State

    @State private var viewModel: YogaViewModel
    @State private var selectedRoutine: YogaRoutine? = nil
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var showCategoryList: Bool = false
    @State private var showPelvicFloor: Bool = false
    @State private var showPoseLibrary: Bool = false

    // MARK: - Environment

    @Environment(\.currentCyclePhase) private var phase

    // MARK: - Init

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: YogaViewModel(yogaRepository: dependencies.yogaRepository))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    headerSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    heroBanner
                        .staggeredAppear(index: 0)

                    if viewModel.isPregnant, let trimester = viewModel.currentTrimester {
                        pregnancySafetyBanner(trimester: trimester)
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    recommendedSection
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                    categoryGridSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                    recentSessionsSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                    quickActionsSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Yoga")
            .onAppear {
                viewModel.currentPhase = phase
                viewModel.loadData()
            }
            .onChange(of: phase) { _, newPhase in
                viewModel.currentPhase = newPhase
                viewModel.refreshRecommendations()
            }
            .navigationDestination(item: $selectedRoutine) { routine in
                RoutineDetailView(routine: routine, viewModel: viewModel)
            }
            .navigationDestination(item: $selectedCategory) { category in
                RoutineListView(category: category, viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showPelvicFloor) {
                PelvicFloorView()
            }
            .navigationDestination(isPresented: $showPoseLibrary) {
                PoseLibraryView()
            }
            .animation(BloomHerTheme.Animation.standard, value: viewModel.isPregnant)
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        Image(BloomIcons.heroYoga)
            .resizable()
            .scaledToFill()
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .overlay(
                LinearGradient(
                    colors: [.clear, BloomHerTheme.Colors.background.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            )
            .padding(.horizontal, BloomHerTheme.Spacing.md)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("Yoga & Movement")
                    .font(BloomHerTheme.Typography.title1)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("\(viewModel.currentPhase.displayName) Phase")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.phase(viewModel.currentPhase))
            }
            Spacer()
            weeklyMinutesBadge
        }
        .staggeredAppear(index: 0)
    }

    private var weeklyMinutesBadge: some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Text("\(viewModel.totalMinutesThisWeek)")
                .font(BloomHerTheme.Typography.heroNumber)
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                .contentTransition(.numericText())
            Text("min\nthis week")
                .font(BloomHerTheme.Typography.caption2)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.primaryRose.opacity(0.10))
        )
    }

    // MARK: - Pregnancy Safety Banner

    private func pregnancySafetyBanner(trimester: Int) -> some View {
        BloomCard(isPhaseAware: false, elevation: .medium) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.heartFilled)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Pregnancy Safety — Trimester \(trimester)")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(trimesterSafetyNote(trimester))
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .staggeredAppear(index: 1)
    }

    private func trimesterSafetyNote(_ trimester: Int) -> String {
        switch trimester {
        case 1:
            return "Avoid lying flat on your back. Stay hydrated and stop if dizzy. Gentle movement is beneficial."
        case 2:
            return "Avoid deep twists and inversions. Use props for balance. Keep intensity moderate."
        default:
            return "Prioritise gentle movement and breath work. Avoid inversions completely. Labour prep poses are safe."
        }
    }

    // MARK: - Recommended Section

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Suggested for You", subtitle: "Based on your \(viewModel.currentPhase.displayName.lowercased()) phase")
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            if viewModel.recommendedRoutines.isEmpty {
                emptyRecommendationsPlaceholder
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: BloomHerTheme.Spacing.md) {
                        ForEach(Array(viewModel.recommendedRoutines.enumerated()), id: \.element.id) { index, routine in
                            RecommendedRoutineCard(
                                routine: routine,
                                phase: viewModel.currentPhase
                            )
                            .staggeredAppear(index: index + 2)
                            .onTapGesture {
                                BloomHerTheme.Haptics.light()
                                selectedRoutine = routine
                            }
                        }
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .padding(.vertical, BloomHerTheme.Spacing.xxs)
                }
            }
        }
    }

    private var emptyRecommendationsPlaceholder: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.yoga)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                Text("No routines found for this phase yet")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Category Grid

    private var categoryGridSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Browse by Category")

            let columns = [
                GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm),
                GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm)
            ]

            LazyVGrid(columns: columns, spacing: BloomHerTheme.Spacing.sm) {
                ForEach(Array(viewModel.visibleCategories.enumerated()), id: \.element) { index, category in
                    CategoryCard(
                        category: category,
                        routineCount: viewModel.routineCount(for: category),
                        isPregnant: viewModel.isPregnant,
                        trimester: viewModel.currentTrimester
                    )
                    .staggeredAppear(index: index + 5)
                    .onTapGesture {
                        BloomHerTheme.Haptics.light()
                        selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Recent Sessions

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Recent Sessions")

            if viewModel.recentSessions.isEmpty {
                BloomCard {
                    VStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.sparkles)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                        Text("No sessions yet — start your first routine!")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(BloomHerTheme.Spacing.lg)
                }
            } else {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(Array(viewModel.recentSessions.enumerated()), id: \.element.id) { index, session in
                        RecentSessionRow(session: session)
                            .staggeredAppear(index: index + 12)
                    }
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Quick Actions")

            HStack(spacing: BloomHerTheme.Spacing.sm) {
                QuickActionButton(
                    title: "Pelvic Floor",
                    color: BloomHerTheme.Colors.accentLavender
                ) {
                    showPelvicFloor = true
                } iconContent: {
                    Image(BloomIcons.pelvicFloor)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                QuickActionButton(
                    title: "Pose Library",
                    color: BloomHerTheme.Colors.sageGreen
                ) {
                    showPoseLibrary = true
                } iconContent: {
                    Image(BloomIcons.poseLibrary)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                QuickActionButton(
                    title: "Breathing",
                    color: BloomHerTheme.Colors.accentPeach
                ) {
                    // Navigate to breathing — handled by the parent tab or dedicated route
                    BloomHerTheme.Haptics.light()
                } iconContent: {
                    Image(BloomIcons.breathing)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
        }
        .staggeredAppear(index: 16)
    }

}

// MARK: - RecommendedRoutineCard

private struct RecommendedRoutineCard: View {
    let routine: YogaRoutine
    let phase: CyclePhase

    var body: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.phase(phase).opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(BloomIcons.yoga)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text(routine.name)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                        Image(BloomIcons.clock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("\(routine.durationMinutes) min")
                    }
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Spacer()
                    DifficultyBadge(difficulty: routine.difficulty, size: .small)
                }
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .frame(width: 160)
        .background(BloomHerTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .bloomShadow(BloomHerTheme.Shadows.medium)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - RecentSessionRow

private struct RecentSessionRow: View {
    let session: YogaSession

    var body: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(BloomHerTheme.Colors.sageGreen.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(BloomIcons.yoga)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(session.routineName)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Text(session.date, style: .date)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Text("·")
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        Text("\(session.durationMinutes) min")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
                Spacer()
                if session.completed {
                    Image(BloomIcons.checkmarkCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(BloomHerTheme.Colors.success)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }
}

// MARK: - QuickActionButton

private struct QuickActionButton<Icon: View>: View {
    let title: String
    let color: Color
    let action: () -> Void
    @ViewBuilder let iconContent: () -> Icon

    var body: some View {
        Button(action: {
            BloomHerTheme.Haptics.light()
            action()
        }) {
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    iconContent()
                }
                Text(title)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(BloomHerTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous))
            .bloomShadow(BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - DifficultyBadge (shared)

struct DifficultyBadge: View {
    enum BadgeSize { case small, medium }
    let difficulty: Difficulty
    var size: BadgeSize = .medium

    var body: some View {
        let iconSize: CGFloat = size == .small ? 10 : 12
        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Image(difficultyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text(difficulty.displayName)
        }
        .font(size == .small ? BloomHerTheme.Typography.caption2 : BloomHerTheme.Typography.caption)
        .foregroundStyle(difficultyColor)
        .padding(.horizontal, BloomHerTheme.Spacing.xxs + 2)
        .padding(.vertical, BloomHerTheme.Spacing.xxxs)
        .background(difficultyColor.opacity(0.12), in: Capsule())
    }

    private var difficultyIcon: String {
        switch difficulty {
        case .beginner:     return BloomIcons.leaf
        case .intermediate: return BloomIcons.flame
        case .advanced:     return BloomIcons.bolt
        }
    }

    private var difficultyColor: Color {
        switch difficulty {
        case .beginner:     return BloomHerTheme.Colors.sageGreen
        case .intermediate: return BloomHerTheme.Colors.accentPeach
        case .advanced:     return BloomHerTheme.Colors.primaryRose
        }
    }
}

// MARK: - Preview

#Preview("Yoga Home — Follicular") {
    let deps = AppDependencies.preview()
    return YogaHomeView(dependencies: deps)
        .environment(\.currentCyclePhase, .follicular)
}

#Preview("Yoga Home — Menstrual") {
    let deps = AppDependencies.preview()
    return YogaHomeView(dependencies: deps)
        .environment(\.currentCyclePhase, .menstrual)
}
