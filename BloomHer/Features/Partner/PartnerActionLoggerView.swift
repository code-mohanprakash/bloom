//
//  PartnerActionLoggerView.swift
//  BloomHer
//
//  Action logging interface for partners. Provides quick-tap actions,
//  today's summary, action history, and encouraging messages.
//

import SwiftUI

// MARK: - PartnerActionLoggerView

struct PartnerActionLoggerView: View {

    // MARK: State

    @Bindable var viewModel: PartnerViewModel
    @State private var customActionText = ""
    @State private var showCustomEntry = false
    @State private var recentlyLoggedId: String?

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                headerSection
                quickActionsGrid
                if !viewModel.todayActions.isEmpty {
                    todaySummary
                }
                encouragementCard
                if showCustomEntry {
                    customEntryCard
                }
                if !viewModel.actionLog.isEmpty {
                    historySection
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Log Support")
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
            Text("Log Something Kind")
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Text("Small acts of care make a big difference. Tap to log what you've done today.")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .staggeredAppear(index: 0)
    }

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        let actions = supportiveActions

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm),
                GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm),
                GridItem(.flexible(), spacing: BloomHerTheme.Spacing.sm)
            ],
            spacing: BloomHerTheme.Spacing.sm
        ) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                ActionTile(
                    title: action.title,
                    icon: action.icon,
                    isBloomIcon: false,
                    isRecentlyLogged: recentlyLoggedId == action.id
                ) {
                    logSupportiveAction(action)
                }
                .staggeredAppear(index: index + 1)
            }

            // Custom action button
            ActionTile(
                title: "Custom",
                icon: BloomIcons.plusCircle,
                isBloomIcon: true,
                isRecentlyLogged: false
            ) {
                withAnimation(BloomHerTheme.Animation.standard) {
                    showCustomEntry.toggle()
                }
                BloomHerTheme.Haptics.light()
            }
        }
    }

    // MARK: - Today's Summary

    private var todaySummary: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack {
                    Image(BloomIcons.checkmarkCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    Text("Today's Support")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(viewModel.todayActions.count)")
                        .font(BloomHerTheme.Typography.title3)
                        .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                }

                ForEach(viewModel.todayActions) { action in
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(action.icon)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            .frame(width: 20)
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
        .staggeredAppear(index: 5)
    }

    // MARK: - Encouragement

    private var encouragementCard: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.heartFilled)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text(encouragementMessage)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    if viewModel.actionsThisWeek > 0 {
                        Text("You've been supportive \(viewModel.actionsThisWeek) time\(viewModel.actionsThisWeek == 1 ? "" : "s") this week!")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                Spacer()
            }
        }
        .staggeredAppear(index: 6)
    }

    private var encouragementMessage: String {
        switch viewModel.actionsThisWeek {
        case 0:     return "Every small gesture counts. Start logging today!"
        case 1...3: return "You're off to a great start. Keep it up!"
        case 4...7: return "Wonderful consistency! Your care is noticed."
        default:    return "You're an amazing partner. Truly exceptional support!"
        }
    }

    // MARK: - Custom Entry

    private var customEntryCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                Text("Custom Action")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    TextField("What did you do?", text: $customActionText)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        .tint(BloomHerTheme.Colors.primaryRose)
                        .padding(BloomHerTheme.Spacing.sm)
                        .background(
                            BloomHerTheme.Colors.background,
                            in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium)
                        )

                    BloomButton("Log", style: .primary, icon: BloomIcons.plus) {
                        guard !customActionText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let action = LoggedAction(title: customActionText, icon: "sparkle")
                        viewModel.logAction(action)
                        customActionText = ""
                        withAnimation(BloomHerTheme.Animation.standard) {
                            showCustomEntry = false
                        }
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("History")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            ForEach(viewModel.actionLog.prefix(20)) { action in
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(action.icon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                        .frame(width: 24)

                    Text(action.title)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    Spacer()

                    Text(action.loggedAt, style: .relative)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }
                .padding(.vertical, BloomHerTheme.Spacing.xs)
            }
        }
        .staggeredAppear(index: 7)
    }

    // MARK: - Actions

    private func logSupportiveAction(_ action: SupportiveActionItem) {
        let logged = LoggedAction(title: action.title, icon: action.icon)
        viewModel.logAction(logged)
        withAnimation(BloomHerTheme.Animation.quick) {
            recentlyLoggedId = action.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(BloomHerTheme.Animation.quick) {
                recentlyLoggedId = nil
            }
        }
    }

    // MARK: - Data

    private var supportiveActions: [SupportiveActionItem] {
        [
            SupportiveActionItem(id: "dinner",      title: "Made dinner",           icon: BloomIcons.nutrition),
            SupportiveActionItem(id: "dishes",      title: "Did the dishes",        icon: BloomIcons.checkmarkCircle),
            SupportiveActionItem(id: "flowers",     title: "Brought flowers",       icon: BloomIcons.leaf),
            SupportiveActionItem(id: "massage",     title: "Gave a massage",        icon: BloomIcons.handTap),
            SupportiveActionItem(id: "bath",        title: "Ran a bath",            icon: BloomIcons.selfcareRelaxation),
            SupportiveActionItem(id: "show",        title: "Watched their show",    icon: BloomIcons.faceSmiling),
            SupportiveActionItem(id: "appointment", title: "Went to appointment",   icon: BloomIcons.calendarCheck),
            SupportiveActionItem(id: "kind",        title: "Said something kind",   icon: BloomIcons.heartFilled),
            SupportiveActionItem(id: "kids",        title: "Took care of kids",     icon: BloomIcons.person),
            SupportiveActionItem(id: "sleep",       title: "Let them sleep in",     icon: BloomIcons.moonStars),
            SupportiveActionItem(id: "snack",       title: "Brought a snack",       icon: BloomIcons.selfcareRelaxation),
        ]
    }
}

// MARK: - SupportiveActionItem

private struct SupportiveActionItem: Identifiable {
    let id: String
    let title: String
    let icon: String
}

// MARK: - ActionTile

private struct ActionTile: View {
    let title: String
    let icon: String
    var isBloomIcon: Bool = false
    let isRecentlyLogged: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: BloomHerTheme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(isRecentlyLogged
                              ? BloomHerTheme.Colors.sageGreen.opacity(0.15)
                              : BloomHerTheme.Colors.primaryRose.opacity(0.1))
                        .frame(width: 48, height: 48)

                    if isRecentlyLogged {
                        Image(BloomIcons.checkmark)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    } else {
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                }

                Text(title)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BloomHerTheme.Spacing.sm)
            .background(BloomHerTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .strokeBorder(
                        isRecentlyLogged
                        ? BloomHerTheme.Colors.sageGreen.opacity(0.3)
                        : BloomHerTheme.Colors.textTertiary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.quick, value: isRecentlyLogged)
    }
}

// MARK: - Preview

#Preview("Partner Action Logger") {
    NavigationStack {
        PartnerActionLoggerView(viewModel: PartnerViewModel(dependencies: AppDependencies.preview()))
    }
}
