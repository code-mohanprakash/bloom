//
//  PersonalizationPageView.swift
//  BloomHer
//
//  Page 4 (final) — user picks their display name and optional permissions.
//
//  Layout:
//    • "Make it yours" heading
//    • BloomTextField for name (optional)
//    • Three toggle cards: Period Reminders / Apple Health / iCloud Backup
//    • "Start Blooming" primary button with loading overlay
//    • Back link
//
//  The button calls viewModel.completeOnboarding(dependencies:) which
//  is async.  While it runs, a loading state is shown over the button.
//

import SwiftUI

// MARK: - PersonalizationPageView

struct PersonalizationPageView: View {

    // MARK: Input

    @Bindable var viewModel: OnboardingViewModel
    let dependencies: AppDependencies

    // MARK: Entrance animation

    @State private var contentVisible: Bool = false

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.lg) {
                Spacer(minLength: BloomHerTheme.Spacing.massive)

                // ── Header ─────────────────────────────────────────────────
                headerSection

                // ── Name field ─────────────────────────────────────────────
                nameSection

                // ── Permission toggles ─────────────────────────────────────
                togglesSection

                Spacer(minLength: BloomHerTheme.Spacing.sm)

                // ── Start button ───────────────────────────────────────────
                startButton

                // ── Back link ──────────────────────────────────────────────
                BloomButton("Back", style: .ghost, size: .medium, icon: BloomIcons.chevronLeft) {
                    viewModel.goBack()
                }
                .disabled(viewModel.isCompleting)

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
            // Celebratory flower
            FlowerShape(
                petalCount: 6,
                size: 72,
                petalColor: BloomHerTheme.Colors.primaryRose,
                centerColor: BloomHerTheme.Colors.accentPeach,
                showStem: false
            )

            Text("Make it yours")
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Text("Everything here is optional and can be changed in Settings anytime.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.personCircle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("What should we call you?")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                BloomTextField(
                    placeholder: "Your name or nickname",
                    icon: BloomIcons.person,
                    text: $viewModel.userName,
                    submitLabel: .done
                )

                Text("We'll use \"friend\" if you leave this blank.")
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }
        }
    }

    // MARK: - Toggles Section

    private var togglesSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            PermissionToggleCard(
                icon: BloomIcons.bell,
                iconColor: BloomHerTheme.Colors.primaryRose,
                title: "Period Reminders",
                description: "Get notified before your period starts",
                isOn: $viewModel.enableNotifications
            )

            PermissionToggleCard(
                icon: BloomIcons.heartMonitor,
                iconColor: BloomHerTheme.Colors.sageGreen,
                title: "Apple Health",
                description: "Sync cycle data with Apple Health",
                isOn: $viewModel.enableHealthKit
            )

            PermissionToggleCard(
                icon: BloomIcons.icloud,
                iconColor: BloomHerTheme.Colors.accentLavender,
                title: "iCloud Backup",
                description: "Back up your data across devices (encrypted)",
                isOn: $viewModel.enableiCloud
            )
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            ZStack {
                if viewModel.isCompleting {
                    // Loading state
                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.9)
                        Text("Setting things up…")
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BloomHerTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        BloomHerTheme.Colors.primaryRose,
                                        BloomHerTheme.Colors.accentPeach
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .padding(.horizontal, BloomHerTheme.Spacing.xl)
                } else {
                    BloomButton(
                        "Start Blooming",
                        style: .primary,
                        size: .large,
                        icon: BloomIcons.flower,
                        isFullWidth: true
                    ) {
                        Task { @MainActor in
                            await viewModel.completeOnboarding(dependencies: dependencies)
                        }
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.xl)
                    .disabled(!viewModel.canAdvance)
                }
            }
            .animation(BloomHerTheme.Animation.standard, value: viewModel.isCompleting)

            // Error banner (non-fatal, shown inline)
            if let errorMessage = viewModel.completionError {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.errorCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(BloomHerTheme.Colors.error)
                    Text(errorMessage)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - PermissionToggleCard

private struct PermissionToggleCard: View {

    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        BloomCard {
            Toggle(isOn: $isOn.animation(BloomHerTheme.Animation.quick)) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 40, height: 40)

                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text(title)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                        Text(description)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .tint(iconColor)
        }
        .accessibilityLabel("\(title). \(description).")
    }
}

// MARK: - Preview

#Preview("Personalisation") {
    ZStack {
        BloomHerTheme.Colors.background.ignoresSafeArea()
        PersonalizationPageView(
            viewModel: OnboardingViewModel(),
            dependencies: AppDependencies.preview()
        )
    }
    .environment(\.currentCyclePhase, .follicular)
}
