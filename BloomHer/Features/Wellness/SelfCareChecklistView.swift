//
//  SelfCareChecklistView.swift
//  BloomHer
//
//  Daily self-care suggestions with interactive checklist.
//  Features:
//  • Phase-specific daily suggestions (from SelfCareData)
//  • Checkable items with satisfying spring completion animation
//  • Category filter chips
//  • Completion progress bar + encouraging messages
//  • History view (past completions)
//  • Kawaii empty state
//

import SwiftUI

// MARK: - SelfCareChecklistView

struct SelfCareChecklistView: View {

    // MARK: State

    @Bindable var viewModel: WellnessViewModel
    @State private var selectedCategory: SelfCareCategory?
    @State private var showHistory: Bool = false
    @State private var animatingItem: String? = nil

    // MARK: Computed

    private var filteredItems: [SelfCareItem] {
        if let category = selectedCategory {
            return viewModel.selfCareSuggestions.filter { $0.category == category }
        }
        return viewModel.selfCareSuggestions
    }

    private var completedCount: Int {
        viewModel.selfCareSuggestions.filter { $0.isCompleted }.count
    }

    private var totalCount: Int {
        viewModel.selfCareSuggestions.count
    }

    private var completionRatio: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var encouragementMessage: String {
        switch completionRatio {
        case 0: return "Every small act of care matters. Start with one!"
        case 0..<0.25: return "You're beginning — keep going, you've got this!"
        case 0.25..<0.5: return "Great progress! Your body is grateful."
        case 0.5..<0.75: return "More than halfway! You're doing wonderfully."
        case 0.75..<1.0: return "Almost there — one last act of love for yourself."
        default: return "You completed all your self-care today! Amazing!"
        }
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                // Progress section
                progressSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 0)

                // Category filter
                categoryFilterRow
                    .staggeredAppear(index: 1)

                // Checklist items
                checklistSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)

                // History toggle
                historySection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 3)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Self-Care")
        .onAppear { viewModel.loadSelfCareSuggestions() }
        .animation(BloomHerTheme.Animation.standard, value: selectedCategory)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        BloomCard(isPhaseAware: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                        Text("Today's Self-Care")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(encouragementMessage)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .lineLimit(2)
                            .animation(BloomHerTheme.Animation.standard, value: completedCount)
                    }

                    Spacer()

                    // Completion ring
                    ZStack {
                        Circle()
                            .stroke(BloomHerTheme.Colors.phase(viewModel.currentPhase).opacity(0.2), lineWidth: 6)
                            .frame(width: 56, height: 56)

                        Circle()
                            .trim(from: 0, to: completionRatio)
                            .stroke(
                                BloomHerTheme.Colors.phase(viewModel.currentPhase),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))
                            .animation(BloomHerTheme.Animation.standard, value: completionRatio)

                        Text("\(completedCount)/\(totalCount)")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }
                }

                BloomProgressBar(
                    progress: completionRatio,
                    color: BloomHerTheme.Colors.phase(viewModel.currentPhase),
                    height: 10,
                    showLabel: true
                )

                // Phase badge
                BloomChip(
                    "\(viewModel.currentPhase.displayName) Phase",
                    icon: viewModel.currentPhase.icon,
                    color: BloomHerTheme.Colors.phase(viewModel.currentPhase),
                    isSelected: true,
                    action: {}
                )
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Category Filter

    private var categoryFilterRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                BloomChip(
                    "All",
                    icon: "square.grid.2x2",
                    color: BloomHerTheme.Colors.textSecondary,
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                ForEach(SelfCareCategory.allCases, id: \.self) { category in
                    BloomChip(
                        category.displayName,
                        icon: category.icon,
                        color: categoryColor(category),
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Checklist

    private var checklistSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            if filteredItems.isEmpty {
                emptyState
            } else {
                ForEach(filteredItems) { item in
                    SelfCareChecklistRow(
                        item: item,
                        phase: viewModel.currentPhase,
                        isAnimating: animatingItem == item.id,
                        onToggle: {
                            triggerCompletionAnimation(item)
                            viewModel.toggleSelfCareItem(item)
                        }
                    )
                }
            }
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Button {
                withAnimation(BloomHerTheme.Animation.standard) {
                    showHistory.toggle()
                }
                BloomHerTheme.Haptics.light()
            } label: {
                HStack {
                    Image(BloomIcons.clockHistory)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("View History")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Image(showHistory ? BloomIcons.chevronUp : BloomIcons.chevronDown)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
                .padding(BloomHerTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                        .fill(BloomHerTheme.Colors.surface)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            if showHistory {
                // History placeholder — in production, query persisted completions
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(mockHistoryEntries) { entry in
                        HistoryEntryRow(entry: entry, phase: viewModel.currentPhase)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.phase(viewModel.currentPhase).opacity(0.12))
                    .frame(width: 100, height: 100)
                KawaiiFace(expression: .neutral, size: 64)
            }
            Text("No items in this category")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            Text("Try selecting a different category or 'All' to see today's suggestions.")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BloomHerTheme.Spacing.xxl)
    }

    // MARK: - Helpers

    private func categoryColor(_ category: SelfCareCategory) -> Color {
        switch category {
        case .relaxation:  return BloomHerTheme.Colors.accentLavender
        case .movement:    return BloomHerTheme.Colors.sageGreen
        case .nutrition:   return BloomHerTheme.Colors.accentPeach
        case .mindfulness: return BloomHerTheme.Colors.primaryRose
        case .social:      return Color(hex: "#F4A0B5").opacity(0.8)
        case .creative:    return BloomHerTheme.Colors.accentPeach
        }
    }

    private func triggerCompletionAnimation(_ item: SelfCareItem) {
        animatingItem = item.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animatingItem = nil
        }
    }

    private var mockHistoryEntries: [SelfCareHistoryEntry] {
        let calendar = Calendar.current
        return (1...3).compactMap { offset -> SelfCareHistoryEntry? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { return nil }
            return SelfCareHistoryEntry(
                id: "\(offset)",
                date: date,
                completedCount: Int.random(in: 2...5),
                totalCount: 6
            )
        }
    }
}

// MARK: - SelfCareChecklistRow

private struct SelfCareChecklistRow: View {
    let item: SelfCareItem
    let phase: CyclePhase
    let isAnimating: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                        .fill(item.isCompleted
                              ? BloomHerTheme.Colors.phase(phase)
                              : Color.clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                                .strokeBorder(
                                    item.isCompleted
                                    ? BloomHerTheme.Colors.phase(phase)
                                    : BloomHerTheme.Colors.textTertiary,
                                    lineWidth: 1.5
                                )
                        )

                    if item.isCompleted {
                        Image(BloomIcons.checkmark)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 13, height: 13)
                            .foregroundStyle(.white)
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .animation(BloomHerTheme.Animation.quick, value: item.isCompleted)

                // Icon — prefer category custom image, fall back to SF Symbol
                if let customImg = item.category.customImage {
                    Image(customImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .opacity(item.isCompleted ? 0.6 : 1.0)
                } else {
                    Image(BloomIcons.sparkles)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 24)
                }

                // Content
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(item.title)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .strikethrough(item.isCompleted, color: BloomHerTheme.Colors.textTertiary)
                    Text(item.description)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                // Category badge
                Text(item.category.displayName)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    .padding(.horizontal, BloomHerTheme.Spacing.xxs + 2)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(BloomHerTheme.Colors.background)
                    )

                // Sparkle when completing
                if isAnimating {
                    SparkleParticleView(color: BloomHerTheme.Colors.phase(phase), count: 6)
                        .frame(width: 40, height: 40)
                        .allowsHitTesting(false)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(item.isCompleted
                          ? BloomHerTheme.Colors.phase(phase).opacity(0.07)
                          : BloomHerTheme.Colors.surface)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.standard, value: item.isCompleted)
    }
}

// MARK: - HistoryEntryRow

private struct HistoryEntryRow: View {
    let entry: SelfCareHistoryEntry
    let phase: CyclePhase

    var body: some View {
        HStack(spacing: BloomHerTheme.Spacing.md) {
            Image(BloomIcons.calendar)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text(entry.date, style: .date)
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Spacer()

            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.phase(phase))
                Text("completed")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.surface)
        )
    }
}

// MARK: - SelfCareHistoryEntry

private struct SelfCareHistoryEntry: Identifiable {
    let id: String
    let date: Date
    let completedCount: Int
    let totalCount: Int
}

// MARK: - Preview

#Preview("Self-Care Checklist") {
    let deps = AppDependencies.preview()
    let vm = WellnessViewModel(dependencies: deps)
    vm.loadDailyContent()
    return NavigationStack {
        SelfCareChecklistView(viewModel: vm)
    }
    .environment(\.currentCyclePhase, .ovulation)
}

#Preview("Self-Care — Luteal") {
    let deps = AppDependencies.preview()
    let vm = WellnessViewModel(dependencies: deps)
    vm.currentPhase = .luteal
    vm.loadDailyContent()
    return NavigationStack {
        SelfCareChecklistView(viewModel: vm)
    }
    .environment(\.currentCyclePhase, .luteal)
}
