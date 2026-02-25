//
//  PoseLibraryView.swift
//  BloomHer
//
//  Searchable, filterable catalogue of all yoga poses.
//  Displays a LazyVGrid of PoseCardView items with filter chips
//  for category, difficulty, and safety level.
//

import SwiftUI

// MARK: - PoseLibraryView

struct PoseLibraryView: View {

    // MARK: - State

    @State private var searchText: String = ""
    @State private var selectedDifficulty: Difficulty? = nil
    @State private var selectedSafety: SafetyLevel? = nil
    @State private var sortOption: SortOption = .alphabetical
    @State private var selectedPose: YogaPose? = nil
    @State private var isPregnant: Bool = false
    @State private var trimester: Int? = nil

    // MARK: - Enums

    enum SortOption: String, CaseIterable {
        case alphabetical = "A–Z"
        case difficulty   = "Difficulty"

        var icon: String {
            switch self {
            case .alphabetical: return "textformat.abc"
            case .difficulty:   return "chart.bar"
            }
        }
    }

    // MARK: - Computed

    private var filteredPoses: [YogaPose] {
        var result = YogaPoseLibrary.allPoses

        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                ($0.sanskritName?.localizedCaseInsensitiveContains(query) ?? false) ||
                $0.muscleGroups.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }

        if let diff = selectedDifficulty {
            result = result.filter { $0.difficulty == diff }
        }

        if let safety = selectedSafety, let tri = trimester {
            result = result.filter { $0.isSafe(forTrimester: tri) == safety }
        }

        switch sortOption {
        case .alphabetical:
            result.sort { $0.name < $1.name }
        case .difficulty:
            result.sort { $0.difficulty.sortOrder < $1.difficulty.sortOrder }
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.lg) {
                searchBar
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                filterRow
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                sortAndCount
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                if filteredPoses.isEmpty {
                    emptyState
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                } else {
                    poseGrid
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Pose Library")
        .sheet(item: $selectedPose) { pose in
            PoseDetailSheet(pose: pose, isPregnant: isPregnant, trimester: trimester)
                .bloomSheet()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        BloomTextField(
            placeholder: "Search poses, muscles...",
            icon: "magnifyingglass",
            text: $searchText
        )
        .staggeredAppear(index: 0)
    }

    // MARK: - Filter Row

    private var filterRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                // Difficulty filters
                ForEach(Difficulty.allCases, id: \.self) { diff in
                    BloomChip(
                        diff.displayName,
                        icon: diff.icon,
                        color: difficultyColor(diff),
                        isSelected: selectedDifficulty == diff
                    ) {
                        withAnimation(BloomHerTheme.Animation.quick) {
                            selectedDifficulty = selectedDifficulty == diff ? nil : diff
                        }
                    }
                }

                Divider().frame(height: 20)

                // Safety filters (only when pregnant)
                if isPregnant {
                    ForEach(SafetyLevel.allCases, id: \.self) { level in
                        BloomChip(
                            level.displayName,
                            icon: level.icon,
                            color: safetyColor(level),
                            isSelected: selectedSafety == level
                        ) {
                            withAnimation(BloomHerTheme.Animation.quick) {
                                selectedSafety = selectedSafety == level ? nil : level
                            }
                        }
                    }
                }
            }
        }
        .staggeredAppear(index: 1)
    }

    // MARK: - Sort & Count

    private var sortAndCount: some View {
        HStack {
            Text("\(filteredPoses.count) pose\(filteredPoses.count == 1 ? "" : "s")")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)

            Spacer()

            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(BloomHerTheme.Animation.quick) {
                            sortOption = option
                        }
                        BloomHerTheme.Haptics.selection()
                    } label: {
                        Text(option.rawValue)
                    }
                }
            } label: {
                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Image(BloomIcons.swap)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(sortOption.rawValue)
                        .font(BloomHerTheme.Typography.footnote)
                }
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            }
        }
        .staggeredAppear(index: 2)
    }

    // MARK: - Pose Grid

    private var poseGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm),
            GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm)
        ]

        return LazyVGrid(columns: columns, spacing: BloomHerTheme.Spacing.sm) {
            ForEach(Array(filteredPoses.enumerated()), id: \.element.id) { index, pose in
                PoseGridTile(
                    pose: pose,
                    isPregnant: isPregnant,
                    trimester: trimester
                )
                .staggeredAppear(index: index + 3)
                .onTapGesture {
                    BloomHerTheme.Haptics.light()
                    selectedPose = pose
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            KawaiiIllustrationView(illustration: .calmFace, size: 90)

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Text("No poses found")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("Try different search terms or clear your filters")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            BloomButton("Clear Filters", style: .outline, size: .medium) {
                searchText = ""
                selectedDifficulty = nil
                selectedSafety = nil
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, BloomHerTheme.Spacing.xxxl)
    }

    // MARK: - Color Helpers

    private func difficultyColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .beginner:     return BloomHerTheme.Colors.sageGreen
        case .intermediate: return BloomHerTheme.Colors.accentPeach
        case .advanced:     return BloomHerTheme.Colors.primaryRose
        }
    }

    private func safetyColor(_ level: SafetyLevel) -> Color {
        switch level {
        case .safe:     return BloomHerTheme.Colors.success
        case .modified: return BloomHerTheme.Colors.warning
        case .avoid:    return BloomHerTheme.Colors.error
        }
    }
}

// MARK: - PoseGridTile

/// Compact 2-column grid cell for the pose library.
private struct PoseGridTile: View {
    let pose: YogaPose
    let isPregnant: Bool
    let trimester: Int?

    var body: some View {
        BloomCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                        .fill(difficultyColor.opacity(0.10))
                        .frame(height: 72)
                    Image(BloomIcons.yoga)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(pose.name)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let sanskrit = pose.sanskritName {
                        Text(sanskrit)
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            .italic()
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }

                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    DifficultyBadge(difficulty: pose.difficulty, size: .small)
                    Spacer()
                    if isPregnant, let trimester {
                        let level = pose.isSafe(forTrimester: trimester)
                        Image(level.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.sm)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var difficultyColor: Color {
        switch pose.difficulty {
        case .beginner:     return BloomHerTheme.Colors.sageGreen
        case .intermediate: return BloomHerTheme.Colors.accentPeach
        case .advanced:     return BloomHerTheme.Colors.primaryRose
        }
    }

    private func levelColor(_ level: SafetyLevel) -> Color {
        switch level {
        case .safe:     return BloomHerTheme.Colors.success
        case .modified: return BloomHerTheme.Colors.warning
        case .avoid:    return BloomHerTheme.Colors.error
        }
    }
}

// MARK: - PoseDetailSheet

/// Full-screen sheet with complete pose information.
struct PoseDetailSheet: View {
    let pose: YogaPose
    let isPregnant: Bool
    let trimester: Int?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    // Hero
                    ZStack {
                        Circle()
                            .fill(BloomHerTheme.Colors.primaryRose.opacity(0.12))
                            .frame(width: 100, height: 100)
                        Image(BloomIcons.yoga)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, BloomHerTheme.Spacing.lg)

                    // Full PoseCardView in expanded mode
                    PoseCardView(
                        pose: pose,
                        isPregnant: isPregnant,
                        trimester: trimester
                    )
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    // Muscle groups
                    if !pose.muscleGroups.isEmpty {
                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                            Text("Muscles Targeted")
                                .font(BloomHerTheme.Typography.headline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                .padding(.horizontal, BloomHerTheme.Spacing.md)

                            ScrollView(.horizontal) {
                                HStack(spacing: BloomHerTheme.Spacing.xs) {
                                    ForEach(pose.muscleGroups, id: \.self) { muscle in
                                        Text(muscle)
                                            .font(BloomHerTheme.Typography.footnote)
                                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                            .padding(.horizontal, BloomHerTheme.Spacing.sm)
                                            .padding(.vertical, BloomHerTheme.Spacing.xxs + 2)
                                            .background(Color.primary.opacity(0.06), in: Capsule())
                                    }
                                }
                                .padding(.horizontal, BloomHerTheme.Spacing.md)
                            }
                        }
                    }
                }
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation(pose.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
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
}

// MARK: - Difficulty Sort Order

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

#Preview("Pose Library") {
    NavigationStack {
        PoseLibraryView()
    }
    .environment(\.currentCyclePhase, .follicular)
}
