//
//  PregnancyDashboardView.swift
//  BloomHer
//
//  Main pregnancy mode home screen. Displays a fruit-baby hero, due date
//  countdown, quick-action grid, development highlights, and a checklist preview.
//

import SwiftUI

// MARK: - PregnancyDashboardView

struct PregnancyDashboardView: View {

    // MARK: State

    @State private var viewModel: PregnancyViewModel
    @State private var navigateToKickCounter = false
    @State private var navigateToContractions = false
    @State private var navigateToWeight = false
    @State private var navigateToAppointments = false
    @State private var navigateToWeekByWeek = false
    @State private var navigateToChecklist = false

    // Keep a reference to the repository for the setup sheet
    private let repository: PregnancyRepositoryProtocol

    // MARK: Init

    init(dependencies: AppDependencies) {
        let repo = dependencies.pregnancyRepository
        self.repository = repo
        _viewModel = State(wrappedValue: PregnancyViewModel(repository: repo))
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                // Mode header
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(BloomIcons.iconPregnant)
                        .resizable()
                        .scaledToFit()
                        .frame(width: BloomHerTheme.IconSize.hero, height: BloomHerTheme.IconSize.hero)

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Pregnancy")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(viewModel.trimesterLabel)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .staggeredAppear(index: 0)

                heroSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                dueDateCountdownCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                quickActionsSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                developmentCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                bodyChangesCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.85)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    }

                checklistPreviewCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
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
        .bloomNavigation("Pregnancy")
        .sheet(isPresented: $viewModel.showSetup, onDismiss: {
            viewModel.refresh()
        }) {
            PregnancySetupSheet(repository: repository)
                .bloomSheet(detents: [.large])
        }
        .navigationDestination(isPresented: $navigateToKickCounter) {
            KickCounterView(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToContractions) {
            ContractionTimerView(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToWeight) {
            WeightTrackingView(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToAppointments) {
            AppointmentListView(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToWeekByWeek) {
            WeekByWeekView(currentWeek: viewModel.currentWeek)
        }
        .navigationDestination(isPresented: $navigateToChecklist) {
            PregnancyChecklistView(viewModel: viewModel)
        }
        .task {
            viewModel.refresh()
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.lg) {
            // Week counter heading
            HStack {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(viewModel.trimesterLabel)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)

                    Text("Week \(viewModel.currentWeek)")
                        .font(BloomHerTheme.Typography.cycleDay)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .contentTransition(.numericText())
                        .animation(BloomHerTheme.Animation.standard, value: viewModel.currentWeek)
                }
                Spacer()

                Button {
                    BloomHerTheme.Haptics.light()
                    navigateToWeekByWeek = true
                } label: {
                    Image(BloomIcons.calendarClock)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(ScaleButtonStyle())
            }

            // Fruit baby illustration
            BloomFruitBaby(week: viewModel.currentWeek, size: 200)
                .frame(maxWidth: .infinity)
                .staggeredAppear(index: 1)
        }
    }

    // MARK: - Due Date Countdown Card

    private var dueDateCountdownCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.pregStorkBundle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("Due Date")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Text(viewModel.dueDateFormatted)
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text("\(viewModel.daysUntilDue)")
                            .font(BloomHerTheme.Typography.heroNumber)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            .contentTransition(.numericText())
                        Text("days to go")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                // Progress bar: weeks completed / 40
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    HStack {
                        Text("Week \(viewModel.currentWeek) of 40")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                        Text("\(Int(viewModel.pregnancyProgress * 100))% complete")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                    BloomProgressBar(
                        progress: viewModel.pregnancyProgress,
                        color: BloomHerTheme.Colors.primaryRose,
                        height: 10
                    )
                }
            }
        }
        .staggeredAppear(index: 2)
    }

    // MARK: - Quick Actions Grid

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Quick Actions")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm)
                ],
                spacing: BloomHerTheme.Spacing.sm
            ) {
                QuickActionTile(
                    title: "Kick Counter",
                    subtitle: "\(viewModel.todaysKickCount) kicks today",
                    icon: BloomIcons.kickCounter,
                    color: BloomHerTheme.Colors.primaryRose,
                    customImage: BloomIcons.pregHeartBaby
                ) { navigateToKickCounter = true }

                QuickActionTile(
                    title: "Contractions",
                    subtitle: viewModel.recentContractions.isEmpty ? "Tap to time" : "\(viewModel.recentContractions.count) logged",
                    icon: BloomIcons.contractionTimer,
                    color: BloomHerTheme.Colors.accentLavender,
                    customImage: BloomIcons.pregBabyFootprints
                ) { navigateToContractions = true }

                QuickActionTile(
                    title: "Weight",
                    subtitle: viewModel.latestWeight.map { String(format: "%.1f kg", $0) } ?? "Tap to log",
                    icon: BloomIcons.weightTracking,
                    color: BloomHerTheme.Colors.sageGreen,
                    customImage: BloomIcons.pregPregnantWoman
                ) { navigateToWeight = true }

                QuickActionTile(
                    title: "Appointments",
                    subtitle: viewModel.upcomingAppointments.isEmpty ? "None upcoming" : "\(viewModel.upcomingAppointments.count) upcoming",
                    icon: BloomIcons.appointments,
                    color: BloomHerTheme.Colors.accentPeach,
                    customImage: BloomIcons.pregUltrasound
                ) { navigateToAppointments = true }
            }
        }
        .staggeredAppear(index: 3)
    }

    // MARK: - Development Card

    private var developmentCard: some View {
        let content = PregnancyWeekData.content(for: viewModel.currentWeek)

        return BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.pregBabyFace)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("This Week's Development")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Text("Wk \(viewModel.currentWeek)")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, BloomHerTheme.Spacing.xs)
                        .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                        .background(BloomHerTheme.Colors.primaryRose, in: Capsule())
                }

                HStack(spacing: BloomHerTheme.Spacing.xl) {
                    measurementPill(label: "Length", value: content.babyLength)
                    measurementPill(label: "Weight", value: content.babyWeight)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(content.developmentHighlights, id: \.self) { highlight in
                        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                            Circle()
                                .fill(BloomHerTheme.Colors.primaryRose)
                                .frame(width: 6, height: 6)
                                .padding(.top, 5)
                            Text(highlight)
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }
                    }
                }

                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                    Image(BloomIcons.book)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 11, height: 11)
                    Text("Source: \(content.source)")
                        .font(BloomHerTheme.Typography.caption2)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
            }
        }
        .staggeredAppear(index: 4)
    }

    private func measurementPill(label: String, value: String) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Text(value)
                .font(BloomHerTheme.Typography.title3)
                .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            Text(label)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Body Changes Card

    private var bodyChangesCard: some View {
        let content = PregnancyWeekData.content(for: viewModel.currentWeek)

        return BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.pregPregnantWoman)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Your Body This Week")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(content.bodyChanges, id: \.self) { change in
                        HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                            Image(BloomIcons.chevronRightCircle)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                                .padding(.top, 2)
                            Text(change)
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }
                    }
                }
            }
        }
        .staggeredAppear(index: 5)
    }

    // MARK: - Checklist Preview Card

    private var checklistPreviewCard: some View {
        let items = ChecklistData.items(for: viewModel.currentWeek)

        return BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.checklist)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Week \(viewModel.currentWeek) Checklist")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    if !items.isEmpty {
                        Text("\(items.count) items")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BloomHerTheme.Spacing.xs)
                            .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                            .background(BloomHerTheme.Colors.sageGreen, in: Capsule())
                    }
                }

                if items.isEmpty {
                    Text("No items for this week — great work!")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(items.prefix(3)) { item in
                            HStack(spacing: BloomHerTheme.Spacing.sm) {
                                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                                    .fill(item.category.color)
                                    .frame(width: 3, height: 20)
                                Image(item.category.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                Text(item.title)
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            }
                        }
                        if items.count > 3 {
                            Text("+ \(items.count - 3) more items")
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        }
                    }

                    BloomButton("View Full Checklist", style: .secondary, icon: BloomIcons.chevronRight, isFullWidth: true) {
                        navigateToChecklist = true
                    }
                }
            }
        }
        .staggeredAppear(index: 6)
    }
}

// MARK: - QuickActionTile

private struct QuickActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var customImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            BloomHerTheme.Haptics.light()
            action()
        }) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                HStack {
                    if let customImage {
                        Image(customImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    } else {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    Spacer()
                    Image(BloomIcons.chevronRight)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }

                Spacer()

                Text(title)
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(BloomHerTheme.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
            .background(BloomHerTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .strokeBorder(color.opacity(0.15), lineWidth: 1.5)
            )
            .bloomShadow(BloomHerTheme.Shadows.small)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview

#Preview("Pregnancy Dashboard") {
    PregnancyDashboardView(dependencies: AppDependencies.preview())
}
