//
//  HomeView.swift
//  BloomHer
//
//  Primary cycle-tracking home screen. The user opens this every day to see
//  their phase, log symptoms, track water, and view their upcoming prediction.
//

import SwiftUI

// MARK: - HomeView

/// The main home dashboard shown in cycle-tracking mode.
///
/// Layout (top to bottom inside a `ScrollView`):
/// 1. Greeting text
/// 2. `BloomFlowerGrowth` hero illustration
/// 3. Days-late warning banner (conditional)
/// 4. Quick-action chips row
/// 5. Today's summary card
/// 6. Water tracker section
/// 7. Phase education card
/// 8. Next period countdown
struct HomeView: View {

    // MARK: - State

    @State private var viewModel: HomeViewModel
    private let cycleRepository: CycleRepositoryProtocol

    // MARK: - Init

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: HomeViewModel(dependencies: dependencies))
        self.cycleRepository = dependencies.cycleRepository
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.lg) {
                greetingSection
                heroIllustrationBanner
                dailyInsightCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 1)
                heroSection
                if let daysLate = viewModel.daysLate, daysLate > 0 {
                    DaysLateBanner(daysLate: daysLate)
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                QuickLogSection(
                    isPeriodActive: viewModel.isPeriodActive,
                    showQuickLog: $viewModel.showQuickLog,
                    showDayDetail: $viewModel.showDayDetail,
                    onLogPeriod: { viewModel.logPeriodStart() },
                    onEndPeriod: { viewModel.endPeriod() }
                )
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .staggeredAppear(index: 3)

                TodaySummaryCard(
                    todayLog: viewModel.todayLog,
                    waterIntake: viewModel.waterIntake,
                    waterGoal: viewModel.waterGoal,
                    onTap: { viewModel.showDayDetail = true }
                )
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .staggeredAppear(index: 4)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.85)
                        .scaleEffect(phase.isIdentity ? 1 : 0.98)
                }

                waterSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 5)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                PhaseInfoCard(phase: viewModel.currentPhase)
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 6)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                nextPeriodSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 7)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }
            }
            .padding(.top, BloomHerTheme.Spacing.md)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .background(phaseGradientOverlay, alignment: .top)
        .refreshable {
            viewModel.refresh()
        }
        .onAppear {
            viewModel.refresh()
        }
        .sheet(isPresented: $viewModel.showQuickLog) {
            SymptomLogQuickSheet(
                viewModel: DayDetailViewModel(
                    date: Date(),
                    cycleRepository: cycleRepository
                )
            )
            .bloomSheet()
        }
        .sheet(isPresented: $viewModel.showDayDetail) {
            DayDetailSheet(
                viewModel: DayDetailViewModel(
                    date: viewModel.todayLog?.date ?? Date(),
                    cycleRepository: cycleRepository
                )
            )
            .bloomSheet(detents: [.large])
        }
        .animation(BloomHerTheme.Animation.standard, value: viewModel.daysLate)
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Phase Gradient

    private var phaseGradientOverlay: some View {
        BloomColors.phaseBackground(for: viewModel.currentPhase)
            .frame(height: 360)
            .ignoresSafeArea(edges: .top)
            .animation(BloomHerTheme.Animation.slow, value: viewModel.currentPhase)
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            // Mode header
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.iconCycle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: BloomHerTheme.IconSize.hero, height: BloomHerTheme.IconSize.hero)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Cycle Tracking")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(viewModel.currentPhase.displayName + " Phase")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.phase(viewModel.currentPhase))
                }
            }

            Text(viewModel.greeting)
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .staggeredAppear(index: 0)
    }

    // MARK: - Daily Insight Card

    /// Rotates through a curated set of phase-aware wellness tips once per day.
    private var dailyInsightCard: some View {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let tip = HomeView.dailyInsights[dayOfYear % HomeView.dailyInsights.count]
        return BloomCard(isTonal: true) {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.periodLoveLetter)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(tip)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Hero Illustration Banner

    private var heroIllustrationBanner: some View {
        Image(BloomIcons.heroIllustration)
            .resizable()
            .scaledToFill()
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: BloomHerTheme.Colors.accentLavender.opacity(0.2), radius: 16, x: 0, y: 8)
            .padding(.horizontal, BloomHerTheme.Spacing.md)
            .staggeredAppear(index: 0)
    }

    /// 15 phase-aware daily insights that rotate by day of year.
    private static let dailyInsights: [String] = [
        "During your menstrual phase, iron-rich foods like lentils and spinach help replenish what your body loses.",
        "The follicular phase brings rising oestrogen — your creativity and verbal skills are naturally sharpest now.",
        "Ovulation day is when your body temperature rises slightly. A BBT thermometer can help you spot the shift.",
        "In the luteal phase, progesterone promotes sleep — lean into early nights and gentle wind-down routines.",
        "Cycle regularity improves with consistent sleep timing. Even weekends benefit from a steady wake time.",
        "Your skin often glows at ovulation due to peak oestrogen. Hydration supports that natural luminosity.",
        "Magnesium in the luteal phase can ease PMS-related headaches, bloating, and mood dips.",
        "The follicular phase is ideal for strength training — your pain tolerance and recovery speed are at their best.",
        "Cervical mucus changes throughout the cycle: dry after your period, then stretchy and clear around ovulation.",
        "Gentle heat on your lower abdomen during menstruation increases blood flow and reduces cramping.",
        "Omega-3 fatty acids from flaxseed or salmon can reduce prostaglandins that cause period pain.",
        "Stress elevates cortisol, which can delay ovulation — short breathing exercises support cycle regularity.",
        "Your luteal phase is a great time for reflection, journalling, and slowing down social commitments.",
        "Vitamin D supports hormone balance — aim for 15 minutes of morning sunlight when possible.",
        "Cycle tracking for 3+ months gives your prediction algorithm much more accurate data to work with."
    ]

    // MARK: - Hero Flower

    private var heroSection: some View {
        ZStack {
            // Layered gradient background
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            viewModel.currentPhase.color.opacity(0.15),
                            viewModel.currentPhase.color.opacity(0.06),
                            BloomHerTheme.Colors.surface.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Glass layer
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))

            // Decorative bokeh circles
            heroDecoCircles

            // Top inner highlight
            VStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.30), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 60)
                Spacer()
            }

            // Soft stroke border
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            viewModel.currentPhase.color.opacity(0.15),
                            Color.white.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            // Content
            VStack(spacing: BloomHerTheme.Spacing.sm) {
                BloomFlowerGrowth(
                    cycleDay:    viewModel.cycleDay,
                    cycleLength: viewModel.cycleLength,
                    phase:       viewModel.currentPhase
                )
                .frame(width: 180, height: 180)
                .frame(maxWidth: .infinity)

                // Cycle day — large hero number
                VStack(spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Day \(viewModel.cycleDay)")
                        .font(BloomHerTheme.Typography.heroNumber)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    viewModel.currentPhase.color,
                                    viewModel.currentPhase.color.opacity(0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .contentTransition(.numericText())
                        .animation(BloomHerTheme.Animation.standard, value: viewModel.cycleDay)

                    Text("of your \(viewModel.cycleLength)-day cycle")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                // Phase badge chip
                BloomChip(
                    "\(viewModel.currentPhase.displayName) Phase",
                    icon: viewModel.currentPhase.icon,
                    color: viewModel.currentPhase.color,
                    isSelected: true,
                    action: {}
                )
            }
            .padding(.vertical, BloomHerTheme.Spacing.xl)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
        .shadow(
            color: viewModel.currentPhase.color.opacity(0.18),
            radius: 24, x: 0, y: 10
        )
        .staggeredAppear(index: 1)
    }

    /// Soft decorative bokeh circles behind the cycle ring.
    private var heroDecoCircles: some View {
        let color = viewModel.currentPhase.color
        return ZStack {
            Circle()
                .fill(color.opacity(0.08))
                .frame(width: 90, height: 90)
                .offset(x: -100, y: -40)
            Circle()
                .fill(BloomHerTheme.Colors.accentPeach.opacity(0.06))
                .frame(width: 60, height: 60)
                .offset(x: 110, y: -60)
            Circle()
                .fill(color.opacity(0.05))
                .frame(width: 120, height: 120)
                .offset(x: 80, y: 70)
            Circle()
                .fill(BloomHerTheme.Colors.accentLavender.opacity(0.05))
                .frame(width: 50, height: 50)
                .offset(x: -90, y: 80)
        }
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous))
    }

    // MARK: - Water Tracker Section

    private var waterSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                BloomHeader(title: "Hydration", subtitle: "Daily goal: \(viewModel.waterGoal) ml")

                HStack(alignment: .center, spacing: BloomHerTheme.Spacing.lg) {
                    BloomWaterDrop(
                        currentMl: viewModel.waterIntake,
                        goalMl:    viewModel.waterGoal
                    )
                    .scaleEffect(0.75, anchor: .center)
                    .frame(width: 100, height: 130)

                    VStack(spacing: BloomHerTheme.Spacing.sm) {
                        waterButton(ml: 250, icon: BloomIcons.drop)
                        waterButton(ml: 500, icon: BloomIcons.drop)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .staggeredAppear(index: 4)
    }

    private func waterButton(ml: Int, icon: String) -> some View {
        BloomButton(
            "+ \(ml) ml",
            style: .secondary,
            size: .small,
            icon: icon,
            isFullWidth: true
        ) {
            viewModel.addWater(ml: ml)
        }
    }

    // MARK: - Next Period Section

    private var nextPeriodSection: some View {
        Group {
            if let daysUntil = viewModel.daysUntilNextPeriod {
                BloomCard {
                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        Image(BloomIcons.periodCalendar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                            Text("Next Period")
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            Text("In \(daysUntil) day\(daysUntil == 1 ? "" : "s")")
                                .font(BloomHerTheme.Typography.headline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }
                        Spacer()
                        if let prediction = viewModel.prediction {
                            Text(prediction.predictedNextStart, style: .date)
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding(BloomHerTheme.Spacing.md)
                }
            } else if let daysLate = viewModel.daysLate, daysLate > 0 {
                // Already shown via DaysLateBanner above; show nothing extra here.
                EmptyView()
            } else {
                // No prediction data available yet.
                BloomCard {
                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        Image(BloomIcons.calendar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Log more cycles to see predictions")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                    }
                    .padding(BloomHerTheme.Spacing.md)
                }
            }
        }
        .staggeredAppear(index: 5)
    }

}

// MARK: - Preview

#Preview("Home View") {
    let dependencies = AppDependencies.preview()
    return HomeView(dependencies: dependencies)
        .environment(AppDependencies.preview())
        .environment(\.currentCyclePhase, .follicular)
}

#Preview("Home View — Ovulation") {
    HomeView(dependencies: AppDependencies.preview())
        .environment(AppDependencies.preview())
        .environment(\.currentCyclePhase, .ovulation)
}
