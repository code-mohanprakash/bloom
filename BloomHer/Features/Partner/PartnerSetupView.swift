//
//  PartnerSetupView.swift
//  BloomHer
//
//  Partner sharing setup screen. Generate or display the share code, configure
//  privacy toggles, manage an active session, and understand how it all works.
//

import SwiftUI

// MARK: - PartnerSetupView

struct PartnerSetupView: View {

    // MARK: State

    @State private var viewModel: PartnerViewModel
    @State private var copiedAnimation = false
    @State private var showCodeEntry = false
    @Environment(\.dismiss) private var dismiss
    private let dependencies: AppDependencies

    // MARK: Init

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(wrappedValue: PartnerViewModel(dependencies: dependencies))
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                    shareCodeSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 0)

                    if viewModel.isSharing {
                        privacyTogglesCard
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 1)

                        activeSharingCard
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 2)

                        revokeSection
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 3)
                    }

                    howItWorksSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: viewModel.isSharing ? 4 : 1)

                    privacyAssuranceCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: viewModel.isSharing ? 5 : 2)

                    // Join as partner link
                    if !viewModel.isSharing {
                        joinAsPartnerLink
                            .padding(.horizontal, BloomHerTheme.Spacing.md)
                            .staggeredAppear(index: 3)
                    }
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Partner Sharing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
            .onAppear { viewModel.loadPartnerData() }
            .confirmationDialog(
                "Revoke Partner Access?",
                isPresented: $viewModel.showRevokeConfirmation,
                titleVisibility: .visible
            ) {
                Button("Revoke Access", role: .destructive) {
                    viewModel.revokeAccess()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your partner will no longer be able to see your cycle information. You can generate a new code at any time.")
            }
            .animation(BloomHerTheme.Animation.standard, value: viewModel.isSharing)
            .sheet(isPresented: $showCodeEntry) {
                PartnerCodeEntryView(dependencies: dependencies)
                    .bloomSheet()
            }
        }
        .environment(\.currentCyclePhase, viewModel.currentPhase)
    }

    // MARK: - Share Code Section

    @ViewBuilder
    private var shareCodeSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text(viewModel.isSharing ? "Your Share Code" : "Share with a Partner")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                if let code = viewModel.shareCode {
                    // Large code display
                    VStack(spacing: BloomHerTheme.Spacing.sm) {
                        Text(code)
                            .font(BloomHerTheme.Typography.shareCode)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            .tracking(8)
                            .frame(maxWidth: .infinity)
                            .padding(BloomHerTheme.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.08))
                            )

                        // Copy + Share buttons
                        HStack(spacing: BloomHerTheme.Spacing.sm) {
                            Button {
                                UIPasteboard.general.string = code
                                BloomHerTheme.Haptics.success()
                                withAnimation(BloomHerTheme.Animation.quick) { copiedAnimation = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { copiedAnimation = false }
                                }
                            } label: {
                                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                                    Image(copiedAnimation ? BloomIcons.checkmarkCircle : BloomIcons.document)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    Text(copiedAnimation ? "Copied!" : "Copy Code")
                                        .foregroundStyle(copiedAnimation ? BloomHerTheme.Colors.sageGreen : BloomHerTheme.Colors.primaryRose)
                                }
                                .font(BloomHerTheme.Typography.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(BloomHerTheme.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous)
                                        .strokeBorder(copiedAnimation ? BloomHerTheme.Colors.sageGreen : BloomHerTheme.Colors.primaryRose, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())

                            ShareLink(item: shareMessage(code: code)) {
                                HStack(spacing: BloomHerTheme.Spacing.xxs) {
                                    Image(BloomIcons.share)
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    Text("Share")
                                }
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(BloomHerTheme.Spacing.sm)
                                .background(BloomColors.primaryRose)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                } else {
                    // No code yet — generate prompt
                    VStack(spacing: BloomHerTheme.Spacing.sm) {
                        Image(BloomIcons.personPlus)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .frame(maxWidth: .infinity)
                            .padding(.top, BloomHerTheme.Spacing.sm)

                        Text("Invite your partner to view your cycle information and get phase-specific support tips.")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)

                        BloomButton("Generate Share Code", style: .primary, icon: BloomIcons.lockShield, isFullWidth: true) {
                            viewModel.generateShareCode()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BloomHerTheme.Spacing.md)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Privacy Toggles

    private var privacyTogglesCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("What to Share")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                toggleRow(
                    icon: BloomIcons.checklist,
                    title: "Phase Information",
                    subtitle: "Current cycle phase and what it means",
                    isOn: $viewModel.sharesPhaseInfo
                )
                Divider()
                toggleRow(
                    icon: BloomIcons.faceSmiling,
                    title: "Mood",
                    subtitle: "How you're feeling today",
                    isOn: $viewModel.sharesMood
                )
                Divider()
                toggleRow(
                    icon: BloomIcons.bolt,
                    title: "Symptoms",
                    subtitle: "Energy, cramps, bloating and more",
                    isOn: $viewModel.sharesSymptoms
                )
                Divider()
                toggleRow(
                    icon: BloomIcons.calendarClock,
                    title: "Appointments",
                    subtitle: "Upcoming health appointments",
                    isOn: $viewModel.sharesAppointments
                )
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)
                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .tint(BloomHerTheme.Colors.primaryRose)
                .labelsHidden()
        }
    }

    // MARK: - Active Sharing Card

    private var activeSharingCard: some View {
        BloomCard {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(BloomHerTheme.Colors.sageGreen.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(BloomIcons.wifi)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                    Text("Sharing Active")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    if let session = viewModel.activeSession {
                        Text("Code: \(session.shareCode) • Created \(session.createdAt, style: .relative) ago")
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }
                Spacer()

                Circle()
                    .fill(BloomHerTheme.Colors.sageGreen)
                    .frame(width: 10, height: 10)
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Revoke Section

    private var revokeSection: some View {
        BloomButton(
            "Revoke Partner Access",
            style: .danger,
            icon: "person.badge.minus",
            isFullWidth: true
        ) {
            viewModel.showRevokeConfirmation = true
        }
    }

    // MARK: - How It Works

    private var howItWorksSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("How It Works")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                let steps: [(String, String)] = [
                    ("Generate", "Tap 'Generate Share Code' to create a unique 6-character code."),
                    ("Share",    "Send the code to your partner via message, AirDrop, or show them."),
                    ("Access",   "Your partner opens BloomHer, selects Partner View, and enters the code."),
                    ("Support",  "They see phase info and personalised support tips — nothing more."),
                ]
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Text("\(index + 1)")
                            .font(BloomHerTheme.Typography.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            .frame(width: 28, height: 28)
                            .background(BloomHerTheme.Colors.primaryRose.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.0)
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            Text(step.1)
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Privacy Assurance

    private var privacyAssuranceCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.lockShield)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Your Privacy is Protected")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                let assurances: [(String, Bool, String)] = [
                    (BloomIcons.lockShield,      true, "Your partner sees phase summaries only — never raw health data."),
                    (BloomIcons.xmarkCircle,     true, "Exact dates, BBT readings, OPK results and journal entries remain private."),
                    (BloomIcons.xmarkCircle,     true, "You can revoke access instantly at any time."),
                    (BloomIcons.checkmarkCircle, true, "All data stays on-device in this version — nothing is sent to a server."),
                ]
                ForEach(Array(assurances.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.xs) {
                        if item.1 {
                            Image(item.0)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                                .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                                .frame(width: 18)
                        } else {
                            Image(item.0)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                                .foregroundStyle(BloomHerTheme.Colors.accentLavender)
                                .frame(width: 18)
                        }
                        Text(item.2)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Join as Partner

    private var joinAsPartnerLink: some View {
        Button {
            BloomHerTheme.Haptics.light()
            showCodeEntry = true
        } label: {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                Image(BloomIcons.personPlus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("Have a code? Join as Partner")
                    .font(BloomHerTheme.Typography.subheadline)
            }
            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
            .frame(maxWidth: .infinity)
            .padding(BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                    .strokeBorder(BloomHerTheme.Colors.primaryRose.opacity(0.3), lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Helpers

    private func shareMessage(code: String) -> String {
        "Hey! I'm using BloomHer to track my cycle. Enter code \(code) in the Partner View to see my cycle phase and get tips on how to support me."
    }
}

// MARK: - Preview

#Preview("Partner Setup — No Code") {
    PartnerSetupView(dependencies: AppDependencies.preview())
        .environment(\.currentCyclePhase, .follicular)
}

#Preview("Partner Setup — Active") {
    let deps = AppDependencies.preview()
    let view = PartnerSetupView(dependencies: deps)
    return view
        .environment(\.currentCyclePhase, .ovulation)
}
