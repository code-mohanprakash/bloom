//
//  SymptomLogQuickSheet.swift
//  BloomHer
//
//  A compact quick-log modal accessible from the home screen.
//  Shows the top-5 moods, a flow intensity selector, and one-tap
//  symptom shortcuts. A "Log More" button opens the full DayDetailSheet.
//  Presented at .medium detent so it doesn't take over the screen.
//

import SwiftUI

// MARK: - SymptomLogQuickSheet

/// A compact quick-log bottom sheet for fast daily logging from the home screen.
///
/// Surfaces the five most-common moods, a full flow intensity selector, and
/// seven high-frequency symptom shortcuts. A "Log More" button expands to the
/// full `DayDetailSheet`. Dismisses itself after saving.
///
/// ```swift
/// .sheet(isPresented: $showQuickLog) {
///     SymptomLogQuickSheet(
///         viewModel: DayDetailViewModel(date: .now, cycleRepository: repo)
///     )
/// }
/// ```
struct SymptomLogQuickSheet: View {

    // MARK: State

    @State var viewModel: DayDetailViewModel
    @State private var showFullLog = false

    // MARK: Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.currentCyclePhase) private var phase

    // MARK: Constants — subset of options shown in quick mode

    private let quickMoods: [Mood] = [.happy, .calm, .tired, .anxious, .irritable]

    private let quickSymptoms: [Symptom] = [
        .headache, .backPain, .bloating, .nausea, .pelvicPain, .insomnia, .acne
    ]

    // MARK: Init

    init(viewModel: DayDetailViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.lg) {
                    // Quick mood strip
                    moodStrip

                    // Flow intensity
                    flowStrip

                    // Symptom shortcuts
                    symptomShortcuts

                    // Actions
                    actionButtons
                        .padding(.bottom, BloomHerTheme.Spacing.xl)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.top, BloomHerTheme.Spacing.sm)
            }
            .bloomBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Quick Log")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(formattedDate)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(BloomIcons.xmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .bloomSheet()
        .sheet(isPresented: $showFullLog) {
            DayDetailSheet(viewModel: viewModel)
                .bloomSheet(detents: [.large])
        }
    }

    // MARK: Mood Strip

    private var moodStrip: some View {
        BloomCard(elevation: .small) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                Label {
                    Text("How are you feeling?")
                } icon: {
                    Image(BloomIcons.faceSmiling)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                .font(BloomHerTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                ScrollView(.horizontal) {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(quickMoods, id: \.self) { mood in
                            quickMoodChip(for: mood)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                }
                .padding(.horizontal, -BloomHerTheme.Spacing.md)
                .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
        }
    }

    @ViewBuilder
    private func quickMoodChip(for mood: Mood) -> some View {
        let isSelected = viewModel.selectedMoods.contains(mood)

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                if isSelected {
                    viewModel.selectedMoods.remove(mood)
                } else {
                    viewModel.selectedMoods.insert(mood)
                }
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? BloomHerTheme.Colors.accentLavender
                              : BloomHerTheme.Colors.accentLavender.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Text(mood.emoji)
                        .font(BloomHerTheme.Typography.title3)
                }

                Text(mood.displayName)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(
                        isSelected
                        ? BloomHerTheme.Colors.accentLavender
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 56)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: Flow Strip

    private var flowStrip: some View {
        BloomCard(elevation: .small) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                Label {
                    Text("Flow")
                } icon: {
                    Image(BloomIcons.drop)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                .font(BloomHerTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                FlowSelector(selected: Binding(
                    get: { viewModel.flowIntensity },
                    set: { viewModel.flowIntensity = $0 }
                ))
                .padding(.horizontal, -BloomHerTheme.Spacing.md)
            }
        }
    }

    // MARK: Symptom Shortcuts

    private var symptomShortcuts: some View {
        BloomCard(elevation: .small) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                Label {
                    Text("Quick Symptoms")
                } icon: {
                    Image(BloomIcons.bolt)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                .font(BloomHerTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xs),
                        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xs),
                        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xs),
                        GridItem(.flexible(), spacing: BloomHerTheme.Spacing.xs)
                    ],
                    spacing: BloomHerTheme.Spacing.xs
                ) {
                    ForEach(quickSymptoms, id: \.self) { symptom in
                        quickSymptomButton(for: symptom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func quickSymptomButton(for symptom: Symptom) -> some View {
        let isSelected = viewModel.selectedSymptoms.contains(symptom)

        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                if isSelected {
                    viewModel.selectedSymptoms.remove(symptom)
                } else {
                    viewModel.selectedSymptoms.insert(symptom)
                }
            }
        } label: {
            VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                Image(symptom.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(
                        isSelected
                        ? .white
                        : BloomHerTheme.Colors.primaryRose
                    )
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                            .fill(isSelected
                                  ? BloomHerTheme.Colors.primaryRose
                                  : BloomHerTheme.Colors.primaryRose.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                            .strokeBorder(
                                BloomHerTheme.Colors.primaryRose.opacity(isSelected ? 0 : 0.3),
                                lineWidth: 1
                            )
                    )

                Text(symptom.displayName)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(
                        isSelected
                        ? BloomHerTheme.Colors.primaryRose
                        : BloomHerTheme.Colors.textSecondary
                    )
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            // Primary save
            BloomButton(
                "Save",
                style: .primary,
                size: .large,
                icon: BloomIcons.checkmark,
                isFullWidth: true
            ) {
                viewModel.save()
                BloomHerTheme.Haptics.success()
                dismiss()
            }

            // Secondary: expand to full sheet
            BloomButton(
                "Log More Details",
                style: .ghost,
                size: .medium,
                icon: BloomIcons.chevronDown,
                isFullWidth: true
            ) {
                showFullLog = true
            }
        }
    }

    // MARK: Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.locale = .current
        return formatter.string(from: viewModel.date)
    }
}

// MARK: - Preview

#Preview("Quick Log Sheet") {
    QuickLogPreviewContainer()
}

private struct QuickLogPreviewContainer: View {
    @State private var showSheet = true
    private let deps = AppDependencies.preview()

    var body: some View {
        Color(hex: "#FFF8F5")
            .ignoresSafeArea()
            .sheet(isPresented: $showSheet) {
                SymptomLogQuickSheet(
                    viewModel: DayDetailViewModel(
                        date: Date(),
                        cycleRepository: deps.cycleRepository
                    )
                )
            }
            .environment(deps)
            .environment(\.currentCyclePhase, .menstrual)
    }
}
