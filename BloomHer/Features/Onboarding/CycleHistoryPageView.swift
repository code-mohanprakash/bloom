//
//  CycleHistoryPageView.swift
//  BloomHer
//
//  Page 2 — collects cycle / pregnancy baseline information.
//
//  The page renders one of two layouts depending on the selected AppMode:
//
//    .cycle / .ttc  →  Last period date + two sliders (period length, cycle length)
//    .pregnant      →  LMP date + optional conception date toggle
//
//  All inputs live inside BloomCards with consistent internal padding.
//  A reassurance tip card at the bottom reduces anxiety about accuracy.
//

import SwiftUI

// MARK: - CycleHistoryPageView

struct CycleHistoryPageView: View {

    // MARK: Input

    @Bindable var viewModel: OnboardingViewModel

    // MARK: Entrance animation

    @State private var contentVisible: Bool = false

    // MARK: Date range helpers

    private var pastYearRange: ClosedRange<Date> {
        let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return start...Date()
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.lg) {
                Spacer(minLength: BloomHerTheme.Spacing.massive)

                // ── Header ─────────────────────────────────────────────────
                headerSection

                // ── Adaptive form ──────────────────────────────────────────
                if viewModel.selectedMode == .pregnant {
                    pregnancyForm
                } else {
                    cycleForm
                }

                // ── Tip card ───────────────────────────────────────────────
                tipCard

                // ── Continue button ────────────────────────────────────────
                BloomButton(
                    "Continue",
                    style: .primary,
                    size: .large,
                    icon: BloomIcons.chevronRight,
                    isFullWidth: true
                ) {
                    viewModel.advance()
                }
                .disabled(!viewModel.canAdvance)
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
                .opacity(viewModel.canAdvance ? 1 : 0.5)
                .animation(BloomHerTheme.Animation.quick, value: viewModel.canAdvance)

                // ── Back link ──────────────────────────────────────────────
                BloomButton("Back", style: .ghost, size: .medium, icon: BloomIcons.chevronLeft) {
                    viewModel.goBack()
                }

                Spacer(minLength: BloomHerTheme.Spacing.massive + BloomHerTheme.Spacing.xl)
            }
            .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 20)
        .onAppear {
            withAnimation(BloomHerTheme.Animation.gentle.delay(0.1)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            Text(viewModel.selectedMode == .pregnant
                 ? "About your pregnancy"
                 : "Tell us about your cycle")
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("This helps us give you accurate predictions from day one.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, BloomHerTheme.Spacing.md)
    }

    // MARK: - Cycle / TTC Form

    private var cycleForm: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {

            // Last period date
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.calendarClock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("When did your last period start?")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }

                    BloomDatePicker(
                        label: "Last period date",
                        date: $viewModel.lastPeriodStartDate,
                        range: pastYearRange
                    )
                }
            }

            // Period length slider
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.drop)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("How long are your periods usually?")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }

                    BloomSlider(
                        value: $viewModel.typicalPeriodLength,
                        in: 2...10,
                        step: 1,
                        label: "Period length",
                        trackColor: BloomHerTheme.Colors.primaryRose
                    ) { value in
                        Text("\(Int(value)) days")
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    }
                }
            }

            // Cycle length slider
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.refresh)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                        Text("How long is your typical cycle?")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }

                    BloomSlider(
                        value: $viewModel.typicalCycleLength,
                        in: 21...45,
                        step: 1,
                        label: "Cycle length",
                        trackColor: BloomHerTheme.Colors.sageGreen
                    ) { value in
                        Text("\(Int(value)) days")
                            .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                    }

                    // Reference marker row
                    HStack {
                        Text("21 days")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        Spacer()
                        Text("28 avg")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        Spacer()
                        Text("45 days")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Pregnancy Form

    private var pregnancyForm: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {

            // LMP date
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    HStack(spacing: BloomHerTheme.Spacing.xs) {
                        Image(BloomIcons.calendarClock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("When was the first day of your last period?")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    }

                    Text("LMP — Last Menstrual Period")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)

                    BloomDatePicker(
                        label: "LMP date",
                        date: $viewModel.lmpDate,
                        range: pastYearRange
                    )

                    // Computed due date preview
                    let dueDate = Calendar.current.date(byAdding: .day, value: 280, to: viewModel.lmpDate) ?? viewModel.lmpDate
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.heartFilled)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 11, height: 11)
                        Text("Estimated due date: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    .padding(.top, BloomHerTheme.Spacing.xxxs)
                }
            }

            // Know conception date toggle + picker
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    Toggle(isOn: $viewModel.knowsConceptionDate.animation(BloomHerTheme.Animation.standard)) {
                        Label {
                            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                                Text("I know my conception date")
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                Text("This can give a more accurate due date")
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            }
                        } icon: {
                            Image(BloomIcons.sparkles)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                    }
                    .tint(BloomHerTheme.Colors.accentPeach)

                    if viewModel.knowsConceptionDate {
                        Divider()
                            .padding(.horizontal, -BloomHerTheme.Spacing.md)

                        BloomDatePicker(
                            label: "Conception date",
                            date: $viewModel.conceptionDate,
                            range: pastYearRange
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
    }

    // MARK: - Tip Card

    private var tipCard: some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.sparkles)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Text("Don't worry if you're not sure — estimates work great! BloomHer will learn and refine over time.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .fill(BloomHerTheme.Colors.accentPeach.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .strokeBorder(BloomHerTheme.Colors.accentPeach.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Previews

#Preview("Cycle Form") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        CycleHistoryPageView(viewModel: OnboardingViewModel())
    }
    .environment(\.currentCyclePhase, .follicular)
}

#Preview("Pregnancy Form") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        let vm = OnboardingViewModel()
        let _ = { vm.selectedMode = .pregnant }()
        CycleHistoryPageView(viewModel: vm)
    }
    .environment(\.currentCyclePhase, .follicular)
}
