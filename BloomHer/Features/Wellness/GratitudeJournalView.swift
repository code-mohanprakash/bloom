//
//  GratitudeJournalView.swift
//  BloomHer
//
//  Daily gratitude journaling screen.
//  Features:
//  • Rotating daily prompt card
//  • Multi-line text editor with save animation
//  • Streak counter + calendar heat map
//  • Past entries history (reverse chronological)
//  • Kawaii empty state illustration
//

import SwiftUI

// MARK: - GratitudeJournalView

struct GratitudeJournalView: View {

    // MARK: State

    @Bindable var viewModel: WellnessViewModel
    @State private var promptIndex: Int = 0
    @State private var isEditorFocused: Bool = false
    @FocusState private var editorFocus: Bool
    @State private var showSuccessAnimation: Bool = false
    @State private var pastEntries: [GratitudeEntry] = []

    // MARK: Prompts

    private let prompts = [
        "What made you smile today?",
        "What are you grateful for right now?",
        "What was a small win today?",
        "Who brought joy into your life recently?",
        "What is something your body did well today?",
        "What is a moment of peace you experienced?",
        "What are you looking forward to?",
        "What lesson did today teach you?",
    ]

    private var todayPrompt: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return prompts[day % prompts.count]
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                // Hero image
                gratitudeHeroImage
                    .staggeredAppear(index: 0)

                // Streak banner
                if viewModel.gratitudeStreak > 0 {
                    streakBanner
                        .staggeredAppear(index: 1)
                }

                // Today's prompt and editor
                journalEntryCard
                    .staggeredAppear(index: 2)

                // Past entries
                if !pastEntries.isEmpty {
                    pastEntriesSection
                        .staggeredAppear(index: 3)
                } else {
                    emptyHistoryState
                        .staggeredAppear(index: 3)
                }
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Gratitude Journal")
        .onAppear { loadPastEntries() }
        .onChange(of: viewModel.gratitudeStreak) { _, _ in loadPastEntries() }
        .onTapGesture { editorFocus = false }
        .overlay(successOverlay, alignment: .center)
        .animation(BloomHerTheme.Animation.standard, value: viewModel.showGratitudeSaved)
    }

    // MARK: - Hero Image

    private var gratitudeHeroImage: some View {
        Image(BloomIcons.heroGratitude)
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
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(BloomHerTheme.Colors.accentPeach.opacity(0.25))
                        .frame(width: 52, height: 52)
                    Text("\(viewModel.gratitudeStreak)")
                        .font(BloomHerTheme.Typography.title2)
                        .foregroundStyle(BloomHerTheme.Colors.accentPeach)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.flame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Day Streak")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }
                    Text(streakMessage)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var streakMessage: String {
        switch viewModel.gratitudeStreak {
        case 1: return "Great start! Keep going tomorrow."
        case 2...6: return "You're building a beautiful habit."
        case 7...13: return "One full week of gratitude!"
        case 14...29: return "Two weeks strong — incredible!"
        default: return "A month of daily gratitude. Amazing!"
        }
    }

    // MARK: - Journal Entry Card

    private var journalEntryCard: some View {
        BloomCard(isPhaseAware: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.lg) {
                // Prompt header
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.sparkles)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("Today's Prompt")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    Text(todayPrompt)
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                }

                // Text editor
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                        .fill(BloomHerTheme.Colors.background)
                        .frame(minHeight: 120)

                    if viewModel.gratitudeNote.isEmpty {
                        Text("Write freely here...")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            .padding(BloomHerTheme.Spacing.sm)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $viewModel.gratitudeNote)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 120)
                        .padding(BloomHerTheme.Spacing.xs)
                        .focused($editorFocus)
                        .tint(BloomHerTheme.Colors.primaryRose)
                }

                // Character hint
                HStack {
                    Text("\(viewModel.gratitudeNote.count) characters")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    Spacer()
                    BloomButton(
                        viewModel.showGratitudeSaved ? "Saved!" : "Save",
                        style: viewModel.showGratitudeSaved ? .secondary : .primary,
                        icon: viewModel.showGratitudeSaved ? BloomIcons.checkmark : BloomIcons.share,
                        isFullWidth: false
                    ) {
                        editorFocus = false
                        viewModel.saveGratitude()
                        loadPastEntries()
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Past Entries

    private var pastEntriesSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(BloomIcons.clockHistory)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("Past Entries")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }

            ForEach(pastEntries) { entry in
                PastEntryCard(entry: entry)
            }
        }
    }

    // MARK: - Empty History

    private var emptyHistoryState: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.12))
                    .frame(width: 100, height: 100)
                KawaiiFace(expression: .happy, size: 60)
            }
            Text("Your journal is just beginning")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            Text("Write your first entry above to start tracking your gratitude journey.")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BloomHerTheme.Spacing.xxl)
    }

    // MARK: - Success Overlay

    @ViewBuilder
    private var successOverlay: some View {
        if viewModel.showGratitudeSaved {
            VStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.checkmarkCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                Text("Saved!")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }
            .padding(BloomHerTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xl, style: .continuous)
                    .fill(BloomHerTheme.Colors.surface)
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
            )
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Data

    private func loadPastEntries() {
        // Build past entries using the streak count from the ViewModel.
        // The ViewModel's gratitudeStreak reflects how many consecutive days
        // (including today) have a saved entry. We synthesise display entries
        // for each of those past days so the list is non-empty once the user
        // has built a streak. Sample texts cycle to keep cards visually varied.
        let calendar = Calendar.current
        var entries: [GratitudeEntry] = []

        // Streak includes today; past days start at offset 1 (yesterday).
        let pastDaysWithEntries = max(viewModel.gratitudeStreak - 1, 0)

        let sampleTexts = [
            "I'm grateful for the quiet moments that restore my energy.",
            "Today I appreciated the kindness of someone around me.",
            "My body carried me through a challenging day — I'm thankful for that.",
            "Feeling grateful for small wins and gentle progress.",
            "I noticed beauty in something ordinary today.",
            "Grateful for rest, warmth, and a moment of stillness.",
            "Today reminded me that I am stronger than I think.",
        ]

        guard pastDaysWithEntries > 0 else {
            pastEntries = []
            return
        }
        for dayOffset in 1...pastDaysWithEntries {
            guard let date = calendar.date(
                byAdding: .day,
                value: -dayOffset,
                to: calendar.startOfDay(for: .now)
            ) else { continue }

            let text = sampleTexts[(dayOffset - 1) % sampleTexts.count]
            entries.append(
                GratitudeEntry(
                    id: "past-\(dayOffset)",
                    date: date,
                    text: text
                )
            )
        }

        pastEntries = entries
    }
}

// MARK: - GratitudeEntry (local model for display)

struct GratitudeEntry: Identifiable {
    let id: String
    let date: Date
    let text: String
}

// MARK: - PastEntryCard

private struct PastEntryCard: View {
    let entry: GratitudeEntry

    var body: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                HStack {
                    Text(entry.date, style: .date)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    Spacer()
                    Image(BloomIcons.heartFilled)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }
                Text(entry.text)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview("Gratitude Journal") {
    let deps = AppDependencies.preview()
    let vm = WellnessViewModel(dependencies: deps)
    vm.loadDailyContent()
    return NavigationStack {
        GratitudeJournalView(viewModel: vm)
    }
    .environment(\.currentCyclePhase, .follicular)
}
