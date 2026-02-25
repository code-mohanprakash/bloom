//
//  RoutineListView.swift
//  BloomHer
//
//  Filterable list of yoga routines for a specific exercise category.
//  Supports text search, a pregnancy-safe-only toggle, and difficulty sorting.
//

import SwiftUI

// MARK: - RoutineListView

struct RoutineListView: View {

    // MARK: - Configuration

    let category: ExerciseCategory
    @Bindable var viewModel: YogaViewModel

    // MARK: - State

    @State private var localSearch: String = ""
    @State private var showSafeOnly: Bool = false
    @State private var selectedRoutine: YogaRoutine? = nil

    // MARK: - Computed

    private var displayRoutines: [YogaRoutine] {
        var result = viewModel.routines(for: category)

        let query = localSearch.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }
        }

        if showSafeOnly && viewModel.isPregnant {
            result = result.filter { $0.safetyNotes.isEmpty || $0.contraindications.isEmpty }
        }

        return result.sorted { $0.difficulty.sortOrder < $1.difficulty.sortOrder }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                categoryHeader
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                searchAndFilter
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                if displayRoutines.isEmpty {
                    emptyState
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                } else {
                    routineList
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation(category.displayName)
        .navigationDestination(item: $selectedRoutine) { routine in
            RoutineDetailView(routine: routine, viewModel: viewModel)
        }
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(BloomIcons.yoga)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(category.displayName)
                        .font(BloomHerTheme.Typography.title2)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("\(viewModel.routineCount(for: category)) routines")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }

            Text(category.description)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .staggeredAppear(index: 0)
    }

    // MARK: - Search & Filter Bar

    private var searchAndFilter: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            BloomTextField(
                placeholder: "Search routines...",
                icon: "magnifyingglass",
                text: $localSearch
            )

            if viewModel.isPregnant {
                HStack {
                    BloomChip(
                        "Pregnancy safe only",
                        icon: BloomIcons.heart,
                        color: BloomHerTheme.Colors.success,
                        isSelected: showSafeOnly
                    ) {
                        showSafeOnly.toggle()
                    }
                    Spacer()
                }
            }
        }
        .staggeredAppear(index: 1)
    }

    // MARK: - Routine List

    private var routineList: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ForEach(Array(displayRoutines.enumerated()), id: \.element.id) { index, routine in
                RoutineCard(
                    routine: routine,
                    isPregnant: viewModel.isPregnant,
                    trimester: viewModel.currentTrimester
                )
                .staggeredAppear(index: index + 2)
                .onTapGesture {
                    BloomHerTheme.Haptics.light()
                    selectedRoutine = routine
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            KawaiiIllustrationView(illustration: .yogaMat, size: 100)

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Text("No routines found")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("Try adjusting your search or removing the filter")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if !localSearch.isEmpty {
                BloomButton("Clear Search", style: .outline, size: .medium) {
                    localSearch = ""
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, BloomHerTheme.Spacing.xxxl)
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch category {
        case .menstrualYoga:      return BloomHerTheme.Colors.primaryRose
        case .follicularEnergy:   return BloomHerTheme.Colors.sageGreen
        case .ovulationPower:     return BloomHerTheme.Colors.accentPeach
        case .lutealWindDown:     return BloomHerTheme.Colors.accentLavender
        case .prenatalT1, .prenatalT2: return BloomColors.follicular
        case .prenatalT3:         return BloomColors.ovulation
        case .postpartumRecovery: return BloomColors.luteal
        case .labourPrep:         return BloomHerTheme.Colors.accentPeach
        case .pelvicFloor:        return BloomHerTheme.Colors.accentLavender
        case .breathing:          return BloomColors.luteal
        }
    }
}

// MARK: - RoutineCard

/// A compact list-style card that summarises a single routine.
struct RoutineCard: View {
    let routine: YogaRoutine
    let isPregnant: Bool
    let trimester: Int?

    var body: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Text(routine.name)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        if routine.isPremium {
                            Image(BloomIcons.starFilled)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                        }
                    }

                    Text(routine.description)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                            Image(BloomIcons.clock)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            Text("\(routine.durationMinutes) min")
                        }
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                            Image(BloomIcons.yoga)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            Text("\(routine.poseCount) poses")
                        }
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                        Spacer()

                        DifficultyBadge(difficulty: routine.difficulty, size: .small)
                    }

                    if isPregnant && !routine.safetyNotes.isEmpty {
                        HStack(spacing: BloomHerTheme.Spacing.xxs) {
                            Image(BloomIcons.info)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(BloomHerTheme.Colors.info)
                            Text("Modifications available")
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.info)
                        }
                    }
                }
                Spacer(minLength: 0)
                Image(BloomIcons.chevronRight)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Difficulty + sortOrder

private extension Difficulty {
    var sortOrder: Int {
        switch self {
        case .beginner:     return 0
        case .intermediate: return 1
        case .advanced:     return 2
        }
    }
}

// MARK: - Preview

#Preview("Routine List — Menstrual") {
    NavigationStack {
        let deps = AppDependencies.preview()
        let vm = YogaViewModel(yogaRepository: deps.yogaRepository)
        let _ = { vm.loadData() }()
        return RoutineListView(category: .menstrualYoga, viewModel: vm)
    }
    .environment(\.currentCyclePhase, .menstrual)
}

#Preview("Routine List — Prenatal T2") {
    NavigationStack {
        let deps = AppDependencies.preview()
        let vm = YogaViewModel(yogaRepository: deps.yogaRepository)
        let _ = {
            vm.loadData()
            vm.isPregnant = true
            vm.currentTrimester = 2
        }()
        return RoutineListView(category: .prenatalT2, viewModel: vm)
    }
}
