//
//  InsightsTabView.swift
//  BloomHer
//
//  Main container for the Insights tab. Shows a cycle overview card and
//  navigation links to the four analytics sub-views: cycle length trends,
//  symptom patterns, mood analysis, and report generation.
//

import SwiftUI

// MARK: - InsightsTabView

/// The root view of the Insights tab.
///
/// Layout (top to bottom inside a `NavigationStack` + `ScrollView`):
/// 1. Cycle overview card — avg length, shortest/longest, total tracked,
///    irregular badge.
/// 2. Navigation links — each is a `BloomCard` with icon, title, subtitle,
///    and a trailing chevron that pushes the corresponding sub-view.
struct InsightsTabView: View {

    // MARK: - State

    @State private var viewModel: InsightsViewModel

    // MARK: - Configuration

    /// Held so it can be forwarded to child views that need direct service access.
    private let dependencies: AppDependencies

    // MARK: - Scaled Metrics

    @ScaledMetric(relativeTo: .body) private var navIconCircleSize: CGFloat = 44
    @ScaledMetric(relativeTo: .body) private var navIconSize: CGFloat = 18

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(wrappedValue: InsightsViewModel(dependencies: dependencies))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    insightsHeroBanner
                        .staggeredAppear(index: 0)

                    overviewCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)

                    navigationSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Insights")
            .refreshable { viewModel.refresh() }
            .onAppear { viewModel.refresh() }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Hero Banner

    private var insightsHeroBanner: some View {
        Image(BloomIcons.heroInsights)
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
            .padding(.horizontal, BloomHerTheme.Spacing.md)
    }

    // MARK: - Overview Card

    private var overviewCard: some View {
        BloomCard(isPhaseAware: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                // Header row
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Cycle Overview")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("\(viewModel.totalCyclesTracked) cycle\(viewModel.totalCyclesTracked == 1 ? "" : "s") tracked")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    Spacer()
                    if viewModel.isIrregular {
                        irregularBadge
                    }
                }

                if viewModel.totalCyclesTracked == 0 {
                    emptyOverviewPrompt
                } else {
                    overviewStatsGrid
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var overviewStatsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: BloomHerTheme.Spacing.sm
        ) {
            overviewStat(
                label: "Average",
                value: viewModel.averageCycleLength > 0
                    ? "\(viewModel.averageCycleLength)d"
                    : "–",
                isHero: true
            )
            overviewStat(
                label: "Shortest",
                value: viewModel.shortestCycle > 0
                    ? "\(viewModel.shortestCycle)d"
                    : "–"
            )
            overviewStat(
                label: "Longest",
                value: viewModel.longestCycle > 0
                    ? "\(viewModel.longestCycle)d"
                    : "–"
            )
        }
    }

    private func overviewStat(label: String, value: String, isHero: Bool = false) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Text(value)
                .font(isHero ? BloomHerTheme.Typography.weekNumber : BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                .contentTransition(.numericText())
            Text(label)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BloomHerTheme.Spacing.sm)
        .background(BloomHerTheme.Colors.primaryRose.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous))
    }

    private var irregularBadge: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs) {
            Image(BloomIcons.warning)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 11, height: 11)
            Text("Irregular")
                .font(BloomHerTheme.Typography.caption2)
        }
        .foregroundStyle(BloomHerTheme.Colors.warning)
        .padding(.horizontal, BloomHerTheme.Spacing.xs)
        .padding(.vertical, BloomHerTheme.Spacing.xxs)
        .background(BloomHerTheme.Colors.warning.opacity(0.12),
                    in: Capsule())
    }

    private var emptyOverviewPrompt: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.chartReport)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
            Text("Log at least two cycles to see your insights")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, BloomHerTheme.Spacing.xs)
    }

    // MARK: - Navigation Section

    private var navigationSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Text("Explore")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .staggeredAppear(index: 1)

            NavigationLink {
                CycleLengthChartView(viewModel: viewModel)
            } label: {
                insightNavRow(
                    icon:       BloomIcons.chartLine,
                    iconColor:  BloomHerTheme.Colors.primaryRose,
                    title:      "Cycle Length Trends",
                    subtitle:   "Track how your cycle changes over time"
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .staggeredAppear(index: 2)

            NavigationLink {
                SymptomHeatmapView(viewModel: viewModel)
            } label: {
                insightNavRow(
                    icon:       BloomIcons.chartBar,
                    iconColor:  BloomHerTheme.Colors.accentPeach,
                    title:      "Symptom Patterns",
                    subtitle:   "Discover your most frequent symptoms"
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .staggeredAppear(index: 3)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.85)
                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
            }

            NavigationLink {
                MoodPatternsView(viewModel: viewModel)
            } label: {
                insightNavRow(
                    icon:       BloomIcons.faceSmiling,
                    iconColor:  BloomHerTheme.Colors.accentLavender,
                    title:      "Mood Analysis",
                    subtitle:   "See how your emotions shift with your cycle"
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .staggeredAppear(index: 4)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.85)
                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
            }

            NavigationLink {
                ReportGeneratorView(viewModel: viewModel, dependencies: dependencies)
            } label: {
                insightNavRow(
                    icon:       BloomIcons.document,
                    iconColor:  BloomHerTheme.Colors.sageGreen,
                    title:      "Reports",
                    subtitle:   "Generate and share a PDF summary"
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .staggeredAppear(index: 5)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.85)
                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
            }
        }
    }

    private func insightNavRow(
        icon:      String,
        iconColor: Color,
        title:     String,
        subtitle:  String
    ) -> some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: navIconCircleSize, height: navIconCircleSize)
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: navIconSize, height: navIconSize)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(title)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(subtitle)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                Spacer()

                Image(BloomIcons.chevronRight)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview("Insights Tab") {
    InsightsTabView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .follicular)
}

#Preview("Insights Tab — Ovulation") {
    InsightsTabView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .ovulation)
}
