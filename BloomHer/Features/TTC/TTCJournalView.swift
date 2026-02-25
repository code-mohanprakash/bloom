//
//  TTCJournalView.swift
//  BloomHer
//
//  TTC-specific journal. Free-text daily notes, emotional check-in,
//  cycle outcome recording, two-week-wait support content, and entry history.
//

import SwiftUI

// MARK: - Supporting Types

/// Emotional state options for a TTC journal entry.
enum TTCEmotion: String, CaseIterable, Identifiable {
    case hopeful
    case anxious
    case neutral
    case tired
    case sad

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .hopeful:  return "🌸"
        case .anxious:  return "😰"
        case .neutral:  return "😌"
        case .tired:    return "😴"
        case .sad:      return "🌧"
        }
    }

    var label: String {
        switch self {
        case .hopeful:  return "Hopeful"
        case .anxious:  return "Anxious"
        case .neutral:  return "Calm"
        case .tired:    return "Tired"
        case .sad:      return "Low"
        }
    }

    var color: Color {
        switch self {
        case .hopeful:  return BloomHerTheme.Colors.primaryRose
        case .anxious:  return BloomHerTheme.Colors.accentPeach
        case .neutral:  return BloomHerTheme.Colors.sageGreen
        case .tired:    return BloomHerTheme.Colors.accentLavender
        case .sad:      return BloomHerTheme.Colors.info
        }
    }
}

/// Outcome of a completed TTC cycle.
enum CycleOutcome: String, CaseIterable, Identifiable {
    case notPregnant      = "not_pregnant"
    case positiveTest     = "positive_test"
    case chemicalPregnancy = "chemical_pregnancy"
    case awaitingResults  = "awaiting"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notPregnant:       return "Not this cycle"
        case .positiveTest:      return "Positive test!"
        case .chemicalPregnancy: return "Chemical pregnancy"
        case .awaitingResults:   return "Still waiting"
        }
    }

    var icon: String {
        switch self {
        case .notPregnant:       return BloomIcons.refresh
        case .positiveTest:      return BloomIcons.plusCircle
        case .chemicalPregnancy: return BloomIcons.heartFilled
        case .awaitingResults:   return BloomIcons.clock
        }
    }

    var color: Color {
        switch self {
        case .notPregnant:       return BloomHerTheme.Colors.textSecondary
        case .positiveTest:      return BloomHerTheme.Colors.sageGreen
        case .chemicalPregnancy: return BloomHerTheme.Colors.error
        case .awaitingResults:   return BloomHerTheme.Colors.accentPeach
        }
    }
}

/// A persisted journal entry.
struct TTCJournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var text: String
    var emotion: TTCEmotion?
    var cycleOutcome: CycleOutcome?

    init(date: Date = Date(), text: String = "", emotion: TTCEmotion? = nil, cycleOutcome: CycleOutcome? = nil) {
        self.id           = UUID()
        self.date         = date
        self.text         = text
        self.emotion      = emotion
        self.cycleOutcome = cycleOutcome
    }
}

// MARK: - TTCJournalView

struct TTCJournalView: View {

    // MARK: State

    let viewModel: TTCViewModel

    @State private var journalText:      String          = ""
    @State private var selectedEmotion:  TTCEmotion?     = nil
    @State private var selectedOutcome:  CycleOutcome?   = nil
    @State private var entries:          [TTCJournalEntry] = []
    @State private var savedConfirmation = false
    @Environment(\.dismiss) private var dismiss

    private static let storageKey = "bloomher.ttcJournal"

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    if viewModel.currentPhase == .luteal {
                        twoWeekWaitCard
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 0)
                    }

                    todayEntryCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)

                    if !entries.isEmpty {
                        historySection
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 2)
                    }

                    encouragementCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 3)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("TTC Journal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
            .onAppear { loadEntries() }
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Two-Week Wait Card

    private var twoWeekWaitCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.clock)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Two Week Wait")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                Text("The luteal phase can feel like the longest two weeks imaginable. You're not alone — the wait is genuinely hard. Here's what might help:")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                let twwTips: [(String, String)] = [
                    (BloomIcons.pulse, "Keep your routine — exercise, work, hobbies keep your mind occupied."),
                    (BloomIcons.clockHistory, "Avoid testing early — tests before 10 DPO are often inaccurate."),
                    (BloomIcons.heartFilled, "Be gentle with yourself — emotions in the TWW are completely valid."),
                    (BloomIcons.personPlus, "Lean on your support people — you don't have to carry this alone."),
                ]
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(Array(twwTips.enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                            Image(tip.0)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .frame(width: 18)
                            Text(tip.1)
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Today Entry Card

    private var todayEntryCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Note")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(Date(), style: .date)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                    Spacer()
                    if savedConfirmation {
                        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                            Image(BloomIcons.checkmarkCircle)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            Text("Saved")
                        }
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                        .transition(.opacity.combined(with: .scale))
                    }
                }

                // Emotion selector
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text("How are you feeling?")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        ForEach(TTCEmotion.allCases) { emotion in
                            emotionButton(emotion)
                        }
                    }
                }

                // Free text
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text("Write anything on your mind")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                            .fill(BloomHerTheme.Colors.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
                            )
                        TextEditor(text: $journalText)
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            .padding(BloomHerTheme.Spacing.sm)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                        if journalText.isEmpty {
                            Text("Your thoughts, feelings, symptoms...")
                                .font(BloomHerTheme.Typography.body)
                                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                                .padding(BloomHerTheme.Spacing.sm + 4)
                                .allowsHitTesting(false)
                        }
                    }
                }

                // Cycle outcome
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text("Cycle outcome (optional)")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    ScrollView(.horizontal) {
                        HStack(spacing: BloomHerTheme.Spacing.xs) {
                            ForEach(CycleOutcome.allCases) { outcome in
                                outcomeButton(outcome)
                            }
                        }
                    }
                }

                BloomButton(
                    "Save Entry",
                    style: .primary,
                    icon: "square.and.pencil",
                    isFullWidth: true
                ) {
                    saveEntry()
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private func emotionButton(_ emotion: TTCEmotion) -> some View {
        let isSelected = selectedEmotion == emotion
        return Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selectedEmotion = isSelected ? nil : emotion
            }
        } label: {
            VStack(spacing: 4) {
                Text(emotion.emoji)
                    .font(BloomHerTheme.Typography.emojiDisplay)
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                Text(emotion.label)
                    .font(BloomHerTheme.Typography.caption2)
                    .foregroundStyle(isSelected ? emotion.color : BloomHerTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .fill(isSelected ? emotion.color.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .strokeBorder(isSelected ? emotion.color : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    private func outcomeButton(_ outcome: CycleOutcome) -> some View {
        let isSelected = selectedOutcome == outcome
        return Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                selectedOutcome = isSelected ? nil : outcome
            }
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                Image(outcome.icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                Text(outcome.displayName)
                    .font(BloomHerTheme.Typography.footnote)
            }
            .foregroundStyle(isSelected ? .white : outcome.color)
            .padding(.horizontal, BloomHerTheme.Spacing.sm)
            .padding(.vertical, BloomHerTheme.Spacing.xxs + 2)
            .background(
                Capsule()
                    .fill(isSelected ? outcome.color : outcome.color.opacity(0.12))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isSelected)
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Past Entries")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .padding(.horizontal, BloomHerTheme.Spacing.md)

            ForEach(groupedEntries, id: \.0) { dateKey, dayEntries in
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    Text(dateKey)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .padding(.horizontal, BloomHerTheme.Spacing.md)

                    ForEach(dayEntries) { entry in
                        journalEntryRow(entry)
                    }
                }
            }
        }
    }

    private var groupedEntries: [(String, [TTCJournalEntry])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var groups: [String: [TTCJournalEntry]] = [:]
        for entry in entries.filter({ !$0.text.isEmpty || $0.emotion != nil }) {
            let key = formatter.string(from: entry.date)
            groups[key, default: []].append(entry)
        }
        return groups.sorted { $0.key > $1.key }
    }

    private func journalEntryRow(_ entry: TTCJournalEntry) -> some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    if let emotion = entry.emotion {
                        Text(emotion.emoji)
                            .font(BloomHerTheme.Typography.callout)
                        Text(emotion.label)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(emotion.color)
                    }
                    Spacer()
                    if let outcome = entry.cycleOutcome {
                        HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                            Image(outcome.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            Text(outcome.displayName)
                        }
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(outcome.color)
                    }
                }
                if !entry.text.isEmpty {
                    Text(entry.text)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
    }

    // MARK: - Encouragement Card

    private var encouragementCard: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                Text(encouragementEmoji)
                    .font(BloomHerTheme.Typography.emojiHero)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text(encouragementTitle)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(encouragementBody)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var encouragementEmoji: String  { ["🌸", "💪", "🌟", "🤍", "🌈"].randomElement() ?? "🌸" }
    private var encouragementTitle: String  {
        switch viewModel.currentPhase {
        case .menstrual:  return "Rest is productive."
        case .follicular: return "Your body is preparing."
        case .ovulation:  return "Your fertile window is here."
        case .luteal:     return "Every cycle brings you closer."
        }
    }
    private var encouragementBody: String {
        switch viewModel.currentPhase {
        case .menstrual:  return "This cycle may not have worked out, but each month brings new opportunity. Rest, reset, and be kind to yourself."
        case .follicular: return "Rising oestrogen is building towards your fertile window. Use this energy boost to take care of yourself."
        case .ovulation:  return "This is the moment your body has been building towards. You're doing everything right."
        case .luteal:     return "The two-week wait tests patience like nothing else. Whatever the outcome, your feelings are valid and you are not alone."
        }
    }

    // MARK: - Persistence

    private func saveEntry() {
        guard !journalText.isEmpty || selectedEmotion != nil || selectedOutcome != nil else { return }
        let entry = TTCJournalEntry(
            date: Date(),
            text: journalText,
            emotion: selectedEmotion,
            cycleOutcome: selectedOutcome
        )
        entries.insert(entry, at: 0)
        persistEntries()
        BloomHerTheme.Haptics.success()
        withAnimation(BloomHerTheme.Animation.quick) { savedConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { savedConfirmation = false }
            journalText    = ""
            selectedEmotion = nil
            selectedOutcome = nil
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([TTCJournalEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func persistEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}

// MARK: - Codable Conformances

extension TTCEmotion: Codable {}
extension CycleOutcome: Codable {}

// MARK: - Preview

#Preview("TTC Journal") {
    TTCJournalView(viewModel: {
        let vm = TTCViewModel(dependencies: AppDependencies.preview())
        vm.refresh()
        return vm
    }())
    .environment(\.currentCyclePhase, .luteal)
}

#Preview("TTC Journal — Ovulation") {
    TTCJournalView(viewModel: {
        let vm = TTCViewModel(dependencies: AppDependencies.preview())
        vm.refresh()
        return vm
    }())
    .environment(\.currentCyclePhase, .ovulation)
}
