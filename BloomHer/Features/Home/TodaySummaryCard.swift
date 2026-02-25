//
//  TodaySummaryCard.swift
//  BloomHer
//
//  A card on the Home screen that summarises what the user has logged today:
//  moods, symptoms, flow level, and a mini water progress bar.
//

import SwiftUI

// MARK: - TodaySummaryCard

/// Summarises the user's daily log on the Home dashboard.
///
/// When nothing has been logged yet the card renders a minimal empty state
/// that invites the user to tap and start logging. When data is present it
/// surfaces mood emojis, symptom chips, a flow level indicator, and a
/// compact water progress bar.
///
/// ```swift
/// TodaySummaryCard(
///     todayLog:    viewModel.todayLog,
///     waterIntake: viewModel.waterIntake,
///     waterGoal:   viewModel.waterGoal,
///     onTap:       { viewModel.showDayDetail = true }
/// )
/// ```
struct TodaySummaryCard: View {

    // MARK: - Input

    let todayLog:    DailyLog?
    let waterIntake: Int
    let waterGoal:   Int
    let onTap:       () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                    BloomHeader(title: "Today's Log", subtitle: dateSubtitle) {
                        Image(BloomIcons.chevronRight)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }

                    if let log = todayLog, hasAnyData(log) {
                        loggedContent(log: log)
                    } else {
                        emptyState
                    }

                    waterProgressRow
                }
                .padding(BloomHerTheme.Spacing.md)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Date Subtitle

    private var dateSubtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Logged Content

    @ViewBuilder
    private func loggedContent(log: DailyLog) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            // Moods row
            if !log.moods.isEmpty {
                moodRow(moods: log.moods)
            }

            // Symptoms row
            if !log.symptoms.isEmpty {
                symptomRow(symptoms: log.symptoms)
            }

            // Flow level
            if let flow = log.flowIntensity {
                flowRow(flow: flow)
            }
        }
    }

    private func moodRow(moods: [Mood]) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
            Text("Mood")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            ScrollView(.horizontal) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(moods, id: \.self) { mood in
                        HStack(spacing: BloomHerTheme.Spacing.xxs) {
                            Text(mood.emoji)
                                .font(BloomHerTheme.Typography.callout)
                            Text(mood.displayName)
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }
                        .padding(.horizontal, BloomHerTheme.Spacing.sm)
                        .padding(.vertical, BloomHerTheme.Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(BloomHerTheme.Colors.accentPeach.opacity(0.18))
                        )
                    }
                }
            }
        }
    }

    private func symptomRow(symptoms: [Symptom]) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
            Text("Symptoms")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            ScrollView(.horizontal) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(symptoms, id: \.self) { symptom in
                        HStack(spacing: BloomHerTheme.Spacing.xxs) {
                            Image(symptom.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                            Text(symptom.displayName)
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                        }
                        .padding(.horizontal, BloomHerTheme.Spacing.sm)
                        .padding(.vertical, BloomHerTheme.Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(BloomHerTheme.Colors.accentLavender.opacity(0.15))
                        )
                    }
                }
            }
        }
    }

    private func flowRow(flow: FlowLevel) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            Text("Flow")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { dot in
                    Circle()
                        .fill(dot <= flow.dotCount
                              ? BloomColors.menstrual
                              : BloomColors.menstrual.opacity(0.18))
                        .frame(width: 7, height: 7)
                }
            }
            Text(flow.displayName)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomColors.menstrual)
        }
    }

    // MARK: - Water Progress

    private var waterProgressRow: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
            HStack {
                Image(BloomIcons.drop)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text("Hydration")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                Spacer()
                Text("\(waterIntake) / \(waterGoal) ml")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .monospacedDigit()
            }
            BloomProgressBar(
                progress: waterGoal > 0 ? min(Double(waterIntake) / Double(waterGoal), 1.0) : 0,
                color:    BloomColors.waterBlue,
                height:   6
            )
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.checklist)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("Nothing logged yet")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                Text("Tap to start tracking today")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            Spacer()
        }
        .padding(.vertical, BloomHerTheme.Spacing.xs)
    }

    // MARK: - Helper

    private func hasAnyData(_ log: DailyLog) -> Bool {
        !log.moods.isEmpty || !log.symptoms.isEmpty || log.flowIntensity != nil
    }
}

// MARK: - Preview

#Preview("Today Summary Card — Empty") {
    TodaySummaryCard(
        todayLog:    nil,
        waterIntake: 500,
        waterGoal:   2000,
        onTap:       {}
    )
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}

#Preview("Today Summary Card — With Data") {
    let container = DataConfiguration.makeInMemoryContainer()
    let log = DailyLog(date: Date())
    log.moods     = [.happy, .energetic]
    log.symptoms  = [.headache, .bloating]
    log.flowIntensity = .medium
    log.waterIntakeMl = 1200
    container.mainContext.insert(log)

    return TodaySummaryCard(
        todayLog:    log,
        waterIntake: 1200,
        waterGoal:   2000,
        onTap:       {}
    )
    .padding(BloomHerTheme.Spacing.md)
    .background(BloomHerTheme.Colors.background)
}
