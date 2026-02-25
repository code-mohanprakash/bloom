//
//  PartnerDashboardView.swift
//  BloomHer
//
//  What the partner sees — a limited, supportive view showing current cycle phase,
//  phase-specific tips, supportive actions, and educational content.
//

import SwiftUI

// MARK: - PartnerDashboardView

struct PartnerDashboardView: View {

    // MARK: State

    @State private var viewModel: PartnerViewModel
    @State private var showActionLogger = false

    // MARK: Init

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: PartnerViewModel(dependencies: dependencies))
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    phaseCard
                        .staggeredAppear(index: 0)

                    howToHelpSection
                        .staggeredAppear(index: 1)

                    quickActionsRow
                        .staggeredAppear(index: 2)

                    educationSection
                        .staggeredAppear(index: 3)

                    if !viewModel.todayActions.isEmpty {
                        todayActionsCard
                            .staggeredAppear(index: 4)
                    }
                }
                .padding(BloomHerTheme.Spacing.md)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Partner View")
            .task { viewModel.loadPartnerData() }
            .sheet(isPresented: $showActionLogger) {
                NavigationStack {
                    PartnerActionLoggerView(viewModel: viewModel)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showActionLogger = false }
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            }
                        }
                }
                .bloomSheet()
            }
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Current Phase Card

    private var phaseCard: some View {
        let phase = viewModel.currentPhase

        return BloomCard(hasPhaseBorder: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                // Phase header
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(phase.color.opacity(0.15))
                            .frame(width: 56, height: 56)
                        if let phaseImg = phase.customImage {
                            Image(phaseImg)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        } else {
                            Image(BloomIcons.phaseMenstrual)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                        }
                    }

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Current Phase")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Text(phase.displayName)
                            .font(BloomHerTheme.Typography.weekNumber)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }

                    Spacer()

                    Text(phase.emoji)
                        .font(BloomHerTheme.Typography.partnerHero)
                }

                // Phase description
                Text(phase.description)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // What this means
                BloomCard {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        Text("What this means")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(phase.color)

                        Text(phaseExplanation(for: phase))
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(BloomHerTheme.Spacing.sm)
                }
            }
        }
    }

    private func phaseExplanation(for phase: CyclePhase) -> String {
        switch phase {
        case .menstrual:
            return "She may experience cramps, fatigue, and lower energy. This is a time for rest and gentle care. Extra patience and comfort go a long way."
        case .follicular:
            return "Energy and mood are rising. She may feel more social, creative, and adventurous. It's a great time to plan fun activities together."
        case .ovulation:
            return "Peak energy and confidence. She may feel especially sociable and energised. This is also the most fertile time of the cycle."
        case .luteal:
            return "Energy is winding down as PMS symptoms may appear. She might feel more sensitive, tired, or have food cravings. Patience and words of affirmation help most."
        }
    }

    // MARK: - How to Help Section

    private var howToHelpSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack {
                Image(BloomIcons.sparkles)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("How to Help Today")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }

            ForEach(viewModel.partnerTips) { tip in
                PartnerEducationCardView(
                    tip: tip,
                    accentColor: viewModel.currentPhase.color
                )
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            quickActionButton(
                title: "Log Support",
                icon: BloomIcons.heartFilled,
                color: BloomHerTheme.Colors.primaryRose
            ) {
                showActionLogger = true
            }

            quickActionButton(
                title: "Learn More",
                icon: BloomIcons.book,
                color: BloomHerTheme.Colors.accentLavender
            ) {
                // Scroll to education section
            }
        }
    }

    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            BloomHerTheme.Haptics.light()
            action()
        }) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text(title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(BloomHerTheme.Spacing.md)
            .background(BloomHerTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
            .bloomShadow(BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Education Section

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack {
                Image(BloomIcons.graduation)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("Understanding the Cycle")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            }

            ForEach(PartnerEducationData.generalEducationCards) { card in
                PartnerEducationCardView(card: card)
            }
        }
    }

    // MARK: - Today's Actions

    private var todayActionsCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack {
                    Image(BloomIcons.starFilled)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Your Support Today")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(viewModel.todayActions.count)")
                        .font(BloomHerTheme.Typography.title3)
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                }

                ForEach(viewModel.todayActions) { action in
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.checkmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                        Text(action.title)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Spacer()
                        Text(action.loggedAt, style: .time)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Partner Dashboard") {
    PartnerDashboardView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .menstrual)
}

#Preview("Partner Dashboard — Ovulation") {
    PartnerDashboardView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .ovulation)
}
