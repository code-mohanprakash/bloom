//
//  PhaseInfoCard.swift
//  BloomHer
//
//  An educational card on the Home screen describing what happens during
//  the user's current cycle phase. Contains a phase-colored left accent bar,
//  a phase icon, description, and actionable tips.
//

import SwiftUI

// MARK: - PhaseInfoCard

/// An educational card that surfaces phase-specific information on the Home screen.
///
/// The card uses a `BloomCard` with `hasPhaseBorder: true` to render a prominent
/// phase-colored left accent. Content includes the phase icon and name, a
/// description of the biological changes, and a compact set of self-care tips.
///
/// ```swift
/// PhaseInfoCard(phase: viewModel.currentPhase)
/// ```
struct PhaseInfoCard: View {

    // MARK: - Input

    let phase: CyclePhase

    // MARK: - Body

    var body: some View {
        BloomCard(hasPhaseBorder: true, isTonal: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                phaseHeader
                descriptionText
                Divider()
                    .background(phase.color.opacity(0.25))
                tipsSection
                learnMoreLink
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .animation(BloomHerTheme.Animation.slow, value: phase)
        .environment(\.currentCyclePhase, phase)
    }

    // MARK: - Phase Header

    /// Maps each cycle phase to a kawaii period icon.
    private var phaseKawaiiIcon: String {
        switch phase {
        case .menstrual:  return BloomIcons.periodBloodDrop
        case .follicular: return BloomIcons.periodCozyTea
        case .ovulation:  return BloomIcons.periodLoveLetter
        case .luteal:     return BloomIcons.periodMoodCloud
        }
    }

    private var phaseHeader: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(phase.color.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(phaseKawaiiIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                Text("\(phase.displayName) Phase")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("What's happening in your body")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
            Spacer()
            Text(phase.emoji)
                .font(BloomHerTheme.Typography.emojiDisplay)
        }
    }

    // MARK: - Description

    private var descriptionText: some View {
        Text(phase.description)
            .font(BloomHerTheme.Typography.body)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(3)
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            Text("Tips for this phase")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            ForEach(tips(for: phase), id: \.self) { tip in
                HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                    Circle()
                        .fill(phase.color)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(tip)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Learn More

    private var learnMoreLink: some View {
        Button {
            // Future: navigate to detailed phase education view
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                Text("Learn more about \(phase.displayName) phase")
                    .font(BloomHerTheme.Typography.footnote)
                Image(BloomIcons.arrowUpCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .foregroundStyle(phase.color)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tips Data

    private func tips(for phase: CyclePhase) -> [String] {
        switch phase {
        case .menstrual:
            return [
                "Rest and gentle movement like yoga or walking can ease cramps.",
                "Heat therapy — a warm pad on your lower abdomen — reduces pain.",
                "Stay hydrated and consider magnesium-rich foods to ease symptoms."
            ]
        case .follicular:
            return [
                "Your energy is rising — great time for higher-intensity workouts.",
                "Introduce new projects and social activities; creativity is peaking.",
                "Focus on protein-rich foods to support follicle development."
            ]
        case .ovulation:
            return [
                "Fertility is at its highest — track cervical mucus and use OPK tests.",
                "Embrace high-energy activities and social engagements.",
                "Zinc and antioxidant-rich foods support egg health."
            ]
        case .luteal:
            return [
                "Progesterone rise may cause PMS — prioritise sleep and self-care.",
                "Complex carbohydrates help stabilise mood and reduce cravings.",
                "Gentle movement and mindfulness support emotional balance."
            ]
        }
    }
}

// MARK: - Preview

#Preview("Phase Info Card — All Phases") {
    ScrollView {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            ForEach(CyclePhase.allCases, id: \.self) { phase in
                PhaseInfoCard(phase: phase)
                    .environment(\.currentCyclePhase, phase)
            }
        }
        .padding(BloomHerTheme.Spacing.md)
    }
    .background(BloomHerTheme.Colors.background)
}
