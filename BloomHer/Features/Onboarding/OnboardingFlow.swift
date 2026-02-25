//
//  OnboardingFlow.swift
//  BloomHer
//
//  Root container for the five-page onboarding experience.
//  Uses a paged TabView driven by OnboardingViewModel.currentPage so that
//  the view-model controls navigation while swipe gestures still work.
//
//  Layout layers (back → front):
//    1. Background gradient
//    2. TabView of page content
//    3. Page-dot indicator row
//    4. Skip button (top-right, hidden on last page)
//

import SwiftUI

// MARK: - OnboardingFlow

struct OnboardingFlow: View {

    // MARK: State

    @State private var viewModel = OnboardingViewModel()
    @Environment(AppDependencies.self) private var dependencies

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Background ──────────────────────────────────────────────────
            backgroundView
                .ignoresSafeArea()

            // ── Page content ────────────────────────────────────────────────
            TabView(selection: $viewModel.currentPage) {
                WelcomePageView(viewModel: viewModel)
                    .tag(0)

                ModeSelectionPageView(viewModel: viewModel)
                    .tag(1)

                CycleHistoryPageView(viewModel: viewModel)
                    .tag(2)

                PrivacyPromisePageView(viewModel: viewModel)
                    .tag(3)

                PersonalizationPageView(viewModel: viewModel, dependencies: dependencies)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(BloomHerTheme.Animation.standard, value: viewModel.currentPage)

            // ── Page dots ───────────────────────────────────────────────────
            pageDotsView
                .padding(.bottom, BloomHerTheme.Spacing.xl)
        }
        .overlay(alignment: .topTrailing) {
            skipButton
                .padding(.top, BloomHerTheme.Spacing.massive)
                .padding(.trailing, BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            BloomHerTheme.Colors.background

            // Radial rose bloom from center-top
            RadialGradient(
                colors: [
                    BloomHerTheme.Colors.primaryRose.opacity(0.10),
                    BloomHerTheme.Colors.primaryRose.opacity(0.0)
                ],
                center: .init(x: 0.5, y: 0.15),
                startRadius: 0,
                endRadius: 340
            )

            // Soft lavender accent in bottom-trailing corner
            RadialGradient(
                colors: [
                    BloomHerTheme.Colors.accentLavender.opacity(0.07),
                    BloomHerTheme.Colors.accentLavender.opacity(0.0)
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 280
            )
        }
    }

    // MARK: - Page Dots

    private var pageDotsView: some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPage
                          ? BloomHerTheme.Colors.primaryRose
                          : BloomHerTheme.Colors.primaryRose.opacity(0.25))
                    .frame(
                        width: index == viewModel.currentPage ? 24 : 8,
                        height: 8
                    )
                    .animation(BloomHerTheme.Animation.quick, value: viewModel.currentPage)
            }
        }
        .padding(.horizontal, BloomHerTheme.Spacing.lg)
        .padding(.vertical, BloomHerTheme.Spacing.sm)
        .background(
            Capsule()
                .fill(BloomHerTheme.Colors.surface.opacity(0.7))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
    }

    // MARK: - Skip Button

    @ViewBuilder
    private var skipButton: some View {
        // Only show before the last page
        if viewModel.currentPage < viewModel.totalPages - 1 {
            Button {
                BloomHerTheme.Haptics.light()
                viewModel.skip()
            } label: {
                Text("Skip")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .padding(.horizontal, BloomHerTheme.Spacing.sm)
                    .padding(.vertical, BloomHerTheme.Spacing.xxs)
                    .background(
                        Capsule()
                            .fill(BloomHerTheme.Colors.surface.opacity(0.7))
                    )
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .animation(BloomHerTheme.Animation.quick, value: viewModel.currentPage)
        }
    }
}

// MARK: - Preview

#Preview("Onboarding Flow") {
    OnboardingFlow()
        .environment(AppDependencies.preview())
        .environment(\.currentCyclePhase, .follicular)
}
