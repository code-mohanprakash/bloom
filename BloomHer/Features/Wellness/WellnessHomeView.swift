//
//  WellnessHomeView.swift
//  BloomHer
//
//  Main Wellness tab screen. A phase-aware ScrollView dashboard with:
//  • Daily affirmation card (gradient, heart favourite)
//  • Water tracker section (BloomWaterDrop + quick-add buttons)
//  • Gratitude journal card
//  • Today's self-care suggestions (horizontal scroll)
//  • Quick-links grid: Breathing, Nutrition, Affirmations, Supplements
//

import SwiftUI

// MARK: - WellnessHomeView

struct WellnessHomeView: View {

    // MARK: State

    @State private var viewModel: WellnessViewModel
    @State private var navigateToBreathing     = false
    @State private var navigateToNutrition     = false
    @State private var navigateToAffirmations  = false
    @State private var navigateToSupplements   = false
    @State private var navigateToWater         = false
    @State private var navigateToGratitude     = false
    @State private var navigateToSelfCare      = false

    // MARK: Environment

    @Environment(\.currentCyclePhase) private var phase

    // MARK: Init

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: WellnessViewModel(dependencies: dependencies))
    }

    // MARK: Body

    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    wellnessHeroBanner
                        .staggeredAppear(index: 0)

                    affirmationSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }

                    waterSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 2)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }

                    gratitudeSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 3)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }

                    selfCareSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 4)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }

                    quickLinksSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 5)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .background(phaseGradientOverlay, alignment: .top)
            .bloomNavigation("Wellness")
            .onAppear { viewModel.loadDailyContent() }
            .environment(\.currentCyclePhase, viewModel.currentPhase)
            .navigationDestination(isPresented: $navigateToBreathing) {
                BreathingExerciseView()
            }
            .navigationDestination(isPresented: $navigateToNutrition) {
                NutritionTipsView(phase: viewModel.currentPhase)
            }
            .navigationDestination(isPresented: $navigateToAffirmations) {
                AffirmationCardView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToSupplements) {
                SupplementReminderView(phase: viewModel.currentPhase)
            }
            .navigationDestination(isPresented: $navigateToWater) {
                WaterTrackerView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToGratitude) {
                GratitudeJournalView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToSelfCare) {
                SelfCareChecklistView(viewModel: viewModel)
            }
    }

    // MARK: - Hero Banner

    private var wellnessHeroBanner: some View {
        Image(BloomIcons.heroWellness)
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

    // MARK: - Phase Gradient

    private var phaseGradientOverlay: some View {
        BloomColors.phaseBackground(for: viewModel.currentPhase)
            .frame(height: 360)
            .ignoresSafeArea(edges: .top)
            .animation(BloomHerTheme.Animation.slow, value: viewModel.currentPhase)
    }

    // MARK: - Affirmation Section

    @ViewBuilder
    private var affirmationSection: some View {
        if let affirmation = viewModel.dailyAffirmation {
            Button {
                navigateToAffirmations = true
            } label: {
                AffirmationBannerCard(
                    affirmation: affirmation,
                    phase: viewModel.currentPhase,
                    isFavourited: viewModel.isAffirmationFavourited,
                    onFavourite: {
                        BloomHerTheme.Haptics.light()
                        viewModel.toggleAffirmationFavourite()
                    }
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Water Section

    private var waterSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        HStack(spacing: BloomHerTheme.Spacing.xs) {
                            Image(BloomIcons.hydration)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                            Text("Hydration")
                                .font(BloomHerTheme.Typography.headline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }
                        Text("Goal: \(viewModel.waterGoal) ml")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .contentTransition(.numericText())
                            .animation(BloomHerTheme.Animation.quick, value: viewModel.waterGoal)
                    }
                    Spacer()
                    Button {
                        navigateToWater = true
                    } label: {
                        Text("Details")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }

                HStack(alignment: .center, spacing: BloomHerTheme.Spacing.lg) {
                    BloomWaterDrop(
                        currentMl: viewModel.waterIntake,
                        goalMl: viewModel.waterGoal
                    )
                    .scaleEffect(0.72, anchor: .center)
                    .frame(width: 94, height: 124)

                    VStack(spacing: BloomHerTheme.Spacing.sm) {
                        waterAddButton(ml: 100, icon: BloomIcons.drop)
                        waterAddButton(ml: 250, icon: BloomIcons.drop)
                        waterAddButton(ml: 500, icon: BloomIcons.hydration)
                    }
                }

                BloomProgressBar(
                    progress: Double(viewModel.waterIntake) / Double(max(viewModel.waterGoal, 1)),
                    color: BloomColors.waterBlue,
                    height: 8,
                    showLabel: true
                )
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private func waterAddButton(ml: Int, icon: String) -> some View {
        BloomButton("+ \(ml) ml", style: .secondary, size: .small, icon: icon, isFullWidth: true) {
            BloomHerTheme.Haptics.medium()
            viewModel.addWater(ml: ml)
        }
    }

    // MARK: - Gratitude Section

    private var gratitudeSection: some View {
        BloomCard(isPhaseAware: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        HStack(spacing: BloomHerTheme.Spacing.xs) {
                            Image(BloomIcons.gratitude)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                            Text("Gratitude Journal")
                                .font(BloomHerTheme.Typography.headline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }
                        if viewModel.gratitudeStreak > 1 {
                            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                                Image(BloomIcons.flame)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                Text("\(viewModel.gratitudeStreak) day streak")
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                    .contentTransition(.numericText())
                                    .animation(BloomHerTheme.Animation.quick, value: viewModel.gratitudeStreak)
                            }
                        }
                    }
                    Spacer()
                    Button {
                        navigateToGratitude = true
                    } label: {
                        Text("View All")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }

                if viewModel.savedGratitudeNote.isEmpty {
                    Text("What are you grateful for today?")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(BloomHerTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                                .fill(BloomHerTheme.Colors.background)
                        )
                        .onTapGesture { navigateToGratitude = true }
                } else {
                    Text(viewModel.savedGratitudeNote)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(BloomHerTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                                .fill(BloomHerTheme.Colors.background)
                        )
                        .onTapGesture { navigateToGratitude = true }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Self-Care Section

    private var selfCareSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Today's Self-Care") {
                Button("See All") { navigateToSelfCare = true }
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .buttonStyle(ScaleButtonStyle())
            }

            ScrollView(.horizontal) {
                HStack(spacing: BloomHerTheme.Spacing.md) {
                    ForEach(viewModel.selfCareSuggestions.prefix(5)) { item in
                        SelfCareHorizontalCard(
                            item: item,
                            phase: viewModel.currentPhase,
                            onToggle: { viewModel.toggleSelfCareItem(item) }
                        )
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.vertical, BloomHerTheme.Spacing.xs)
            }
            .padding(.horizontal, -BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Quick Links Grid

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Explore Wellness")

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: BloomHerTheme.Spacing.sm
            ) {
                QuickLinkCard(
                    title: "Breathing",
                    icon: BloomIcons.breathing,
                    color: BloomHerTheme.Colors.accentLavender,
                    customImage: BloomIcons.breathing,
                    action: { navigateToBreathing = true }
                )
                QuickLinkCard(
                    title: "Nutrition",
                    icon: BloomIcons.nutrition,
                    color: BloomHerTheme.Colors.sageGreen,
                    customImage: BloomIcons.nutrition,
                    action: { navigateToNutrition = true }
                )
                QuickLinkCard(
                    title: "Affirmations",
                    icon: BloomIcons.affirmations,
                    color: BloomHerTheme.Colors.primaryRose,
                    customImage: BloomIcons.affirmations,
                    action: { navigateToAffirmations = true }
                )
                QuickLinkCard(
                    title: "Supplements",
                    icon: BloomIcons.supplements,
                    color: BloomHerTheme.Colors.accentPeach,
                    customImage: BloomIcons.supplements,
                    action: { navigateToSupplements = true }
                )
            }
        }
    }
}

// MARK: - AffirmationBannerCard

private struct AffirmationBannerCard: View {
    let affirmation: AffirmationContent
    let phase: CyclePhase
    let isFavourited: Bool
    let onFavourite: () -> Void

    private var gradient: LinearGradient {
        let base = BloomHerTheme.Colors.phase(phase)
        return LinearGradient(
            colors: [base.opacity(0.85), base.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Gradient background
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(gradient)

            // Glass overlay on top of gradient
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.15))

            // Inner highlight
            VStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 50)
                Spacer()
            }

            // Glass border
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.xxl, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.40), Color.white.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                BloomChip(
                    affirmation.category.displayName,
                    icon: affirmation.category.icon,
                    color: .white,
                    isSelected: true,
                    action: {}
                )

                Spacer()

                Text("\u{201C}\(affirmation.text)\u{201D}")
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)

                Text("Swipe for more")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(BloomHerTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Favourite button with custom icon
            Button {
                onFavourite()
            } label: {
                Image(BloomIcons.heart)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .colorMultiply(isFavourited ? BloomColors.primaryRose : .white)
                    .opacity(isFavourited ? 1.0 : 0.85)
                    .scaleEffect(isFavourited ? 1.15 : 1.0)
                    .animation(BloomHerTheme.Animation.quick, value: isFavourited)
                    .padding(BloomHerTheme.Spacing.md)
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("Toggle favourite")
        }
        .frame(minHeight: 180)
        .shadow(
            color: BloomHerTheme.Colors.phase(phase).opacity(0.35),
            radius: 20,
            x: 0,
            y: 8
        )
    }
}

// MARK: - SelfCareHorizontalCard

private struct SelfCareHorizontalCard: View {
    let item: SelfCareItem
    let phase: CyclePhase
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack {
                    if let customImg = item.category.customImage {
                        Image(customImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .colorMultiply(item.isCompleted ? .white : BloomHerTheme.Colors.phase(phase))
                    } else {
                        Image(BloomIcons.sparkles)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                    if item.isCompleted {
                        Image(BloomIcons.checkmarkCircle)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .colorMultiply(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(item.title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(item.isCompleted ? .white : BloomHerTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.description)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(item.isCompleted ? .white.opacity(0.8) : BloomHerTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(BloomHerTheme.Spacing.md)
            .frame(width: 148, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .fill(item.isCompleted
                          ? BloomHerTheme.Colors.phase(phase)
                          : BloomHerTheme.Colors.surface)
            )
            .bloomShadow(BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.standard, value: item.isCompleted)
    }
}

// MARK: - QuickLinkCard

private struct QuickLinkCard: View {
    let title: String
    let icon: String
    let color: Color
    var customImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Group {
                    if let customImage {
                        Image(customImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    } else {
                        Image(BloomIcons.sparkles)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(color.opacity(0.15))
                )
                Text(title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Spacer()
                Image(BloomIcons.chevronRight)
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
            .bloomShadow(BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview

#Preview("Wellness Home") {
    let deps = AppDependencies.preview()
    return WellnessHomeView(dependencies: deps)
        .environment(\.currentCyclePhase, .follicular)
}

#Preview("Wellness Home — Luteal") {
    let deps = AppDependencies.preview()
    return WellnessHomeView(dependencies: deps)
        .environment(\.currentCyclePhase, .luteal)
}
