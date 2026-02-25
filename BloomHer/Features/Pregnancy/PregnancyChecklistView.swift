//
//  PregnancyChecklistView.swift
//  BloomHer
//
//  Weekly checklist view with category filtering, trimester grouping,
//  completion persistence, and animated progress indicators.
//

import SwiftUI

// MARK: - PregnancyChecklistView

struct PregnancyChecklistView: View {

    // MARK: State

    @State private var viewModel: PregnancyViewModel
    @State private var selectedFilter: FilterMode = .currentWeek
    @State private var completedItemIDs: Set<String> = []
    @State private var selectedCategory: ChecklistCategory? = nil

    // MARK: Filter Mode

    enum FilterMode: String, CaseIterable {
        case currentWeek = "This Week"
        case trimester   = "Trimester"
        case all         = "All"
    }

    private struct ChecklistGroup: Identifiable {
        let category: ChecklistCategory
        let items: [ChecklistItemData]
        var id: String { category.rawValue }
    }

    // MARK: Init

    init(viewModel: PregnancyViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: Computed

    private var currentWeek: Int { viewModel.currentWeek }
    private var trimester: Int { viewModel.trimester }

    private var filteredItems: [ChecklistItemData] {
        let base: [ChecklistItemData]
        switch selectedFilter {
        case .currentWeek:
            base = ChecklistData.newItems(for: currentWeek)
        case .trimester:
            base = ChecklistData.itemsByTrimester(upToWeek: currentWeek)[trimester] ?? []
        case .all:
            base = ChecklistData.items(for: currentWeek)
        }

        if let cat = selectedCategory {
            return base.filter { $0.category == cat }
        }
        return base
    }

    private var groupedItems: [ChecklistGroup] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category }
        return ChecklistCategory.allCases.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            return ChecklistGroup(category: cat, items: items)
        }
    }

    private var completedCount: Int {
        filteredItems.filter { completedItemIDs.contains($0.id) }.count
    }

    private var progressFraction: Double {
        guard !filteredItems.isEmpty else { return 0 }
        return Double(completedCount) / Double(filteredItems.count)
    }

    private var newItemCount: Int {
        ChecklistData.newItems(for: currentWeek)
            .filter { !completedItemIDs.contains($0.id) }.count
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                progressHeader
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                filterBar
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                categoryFilterStrip
                    .padding(.leading, BloomHerTheme.Spacing.md)

                if filteredItems.isEmpty {
                    emptyState
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                } else {
                    checklistContent
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Checklist")
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Week \(currentWeek) Progress")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(viewModel.trimesterLabel)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }

                    Spacer()

                    // New items badge
                    if newItemCount > 0 && selectedFilter == .currentWeek {
                        Text("\(newItemCount) new")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BloomHerTheme.Spacing.xs)
                            .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                            .background(BloomHerTheme.Colors.primaryRose, in: Capsule())
                    }
                }

                HStack {
                    Text("\(completedCount)/\(filteredItems.count) complete")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Spacer()
                    Text("\(Int(progressFraction * 100))%")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }

                BloomProgressBar(
                    progress: progressFraction,
                    color: BloomHerTheme.Colors.primaryRose,
                    height: 10
                )

                if progressFraction >= 1.0 && !filteredItems.isEmpty {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.starFilled)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text("All done for this view — great work!")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(BloomHerTheme.Animation.standard, value: progressFraction)
                }
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        BloomSegmentedControl(
            options: FilterMode.allCases.map { $0.rawValue },
            selectedIndex: Binding(
                get: { FilterMode.allCases.firstIndex(of: selectedFilter) ?? 0 },
                set: { idx in
                    withAnimation(BloomHerTheme.Animation.standard) {
                        selectedFilter = FilterMode.allCases[idx]
                    }
                    selectedCategory = nil
                    BloomHerTheme.Haptics.selection()
                }
            )
        )
    }

    // MARK: - Category Filter Strip

    private var categoryFilterStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                // "All" chip
                categoryChip(label: "All", color: BloomHerTheme.Colors.textSecondary, isSelected: selectedCategory == nil) {
                    withAnimation(BloomHerTheme.Animation.quick) { selectedCategory = nil }
                    BloomHerTheme.Haptics.selection()
                }

                ForEach(ChecklistCategory.allCases, id: \.self) { category in
                    categoryChip(
                        label: category.rawValue,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(BloomHerTheme.Animation.quick) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                        BloomHerTheme.Haptics.selection()
                    }
                }
            }
            .padding(.trailing, BloomHerTheme.Spacing.md)
        }
    }

    private func categoryChip(label: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, BloomHerTheme.Spacing.sm)
                .padding(.vertical, BloomHerTheme.Spacing.xxs)
                .background(Capsule().fill(isSelected ? color : color.opacity(0.12)))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Checklist Content

    private var checklistContent: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            ForEach(groupedItems) { group in
                categorySection(category: group.category, items: group.items)
            }
        }
    }

    private func categorySection(category: ChecklistCategory, items: [ChecklistItemData]) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(category.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(category.color, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small))

                Text(category.rawValue)
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Spacer()

                let doneCount = items.filter { completedItemIDs.contains($0.id) }.count
                Text("\(doneCount)/\(items.count)")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                ForEach(items) { item in
                    ChecklistItemRow(
                        item: item,
                        isCompleted: completedItemIDs.contains(item.id),
                        accentColor: category.color
                    ) {
                        toggleItem(item)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.md) {
                Image(BloomIcons.checklist)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                Text("No items match the current filter")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.xl)
        }
    }

    // MARK: - Actions

    private func toggleItem(_ item: ChecklistItemData) {
        withAnimation(BloomHerTheme.Animation.quick) {
            if completedItemIDs.contains(item.id) {
                completedItemIDs.remove(item.id)
                BloomHerTheme.Haptics.light()
            } else {
                completedItemIDs.insert(item.id)
                BloomHerTheme.Haptics.success()
            }
        }
    }

}

// MARK: - ChecklistItemRow

private struct ChecklistItemRow: View {
    let item: ChecklistItemData
    let isCompleted: Bool
    let accentColor: Color
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                // Left accent bar
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                    .fill(isCompleted ? BloomHerTheme.Colors.sageGreen : accentColor)
                    .frame(width: 3)
                    .animation(BloomHerTheme.Animation.quick, value: isCompleted)

                // Checkbox
                Image(isCompleted ? BloomIcons.checkmarkCircle : BloomIcons.checkmark)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isCompleted ? BloomHerTheme.Colors.sageGreen : BloomHerTheme.Colors.textTertiary)
                    .animation(BloomHerTheme.Animation.quick, value: isCompleted)

                // Text content
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(item.title)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(isCompleted ? BloomHerTheme.Colors.textTertiary : BloomHerTheme.Colors.textPrimary)
                        .strikethrough(isCompleted, color: BloomHerTheme.Colors.textTertiary)
                        .animation(BloomHerTheme.Animation.quick, value: isCompleted)

                    Text("Week \(item.week) · \(item.category.rawValue)")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }

                Spacer()
            }
            .padding(BloomHerTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .fill(isCompleted ? BloomHerTheme.Colors.sageGreen.opacity(0.06) : BloomHerTheme.Colors.surface)
            )
            .bloomShadow(BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

extension ChecklistCategory {
    var color: Color {
        switch self {
        case .medical:
            return BloomHerTheme.Colors.primaryRose
        case .preparation:
            return BloomHerTheme.Colors.accentLavender
        case .shopping:
            return BloomHerTheme.Colors.accentPeach
        case .selfCare:
            return BloomHerTheme.Colors.sageGreen
        case .administrative:
            return BloomHerTheme.Colors.info
        }
    }
}

// MARK: - Preview

#Preview("Pregnancy Checklist") {
    NavigationStack {
        PregnancyChecklistView(viewModel: PregnancyViewModel(repository: PreviewChecklistRepo()))
    }
}

#Preview("Checklist — Week 20") {
    struct ChecklistWeek20: View {
        @State private var vm = PregnancyViewModel(repository: PreviewChecklistRepo())
        var body: some View {
            NavigationStack {
                PregnancyChecklistView(viewModel: vm)
            }
        }
    }
    return ChecklistWeek20()
}

private class PreviewChecklistRepo: PregnancyRepositoryProtocol {
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
