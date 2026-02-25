//
//  PartnerCodeEntryView.swift
//  BloomHer
//
//  Code entry screen for the receiving partner. Enter the 6-character share
//  code provided by the sharing partner to join their session and view
//  phase-specific support tips.
//

import SwiftUI

// MARK: - PartnerCodeEntryView

struct PartnerCodeEntryView: View {

    // MARK: State

    @State private var viewModel: PartnerViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCodeFieldFocused: Bool
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
                    headerSection
                        .staggeredAppear(index: 0)

                    codeEntryCard
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)

                    stepsSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 2)

                    privacyNote
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 3)
                }
                .padding(.top, BloomHerTheme.Spacing.lg)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Join as Partner")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
            .onAppear { isCodeFieldFocused = true }
            .fullScreenCover(isPresented: .init(
                get: { viewModel.hasJoined },
                set: { if !$0 { dismiss() } }
            )) {
                if viewModel.joinedSession != nil {
                    PartnerDashboardView(dependencies: dependencies)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            Image(BloomIcons.personPlus)
                .resizable()
                .scaledToFit()
                .frame(width: BloomHerTheme.IconSize.illustration, height: BloomHerTheme.IconSize.illustration)

            Text("Enter Partner Code")
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Text("Ask your partner for their 6-character BloomHer share code.")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BloomHerTheme.Spacing.md)
    }

    // MARK: - Code Entry Card

    private var codeEntryCard: some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.md) {
                TextField("XXXXXX", text: $viewModel.enteredCode)
                    .font(BloomHerTheme.Typography.shareCode)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .focused($isCodeFieldFocused)
                    .onChange(of: viewModel.enteredCode) { _, newValue in
                        // Filter to valid alphabet and limit to 6 chars
                        let filtered = String(
                            newValue.uppercased()
                                .filter { "BCDFGHJKLMNPQRSTVWXYZ23456789".contains($0) }
                                .prefix(6)
                        )
                        if filtered != newValue {
                            viewModel.enteredCode = filtered
                        }
                        // Clear error when user edits
                        viewModel.codeEntryError = nil
                    }
                    .padding(BloomHerTheme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                            .fill(viewModel.codeEntryError != nil
                                  ? BloomHerTheme.Colors.error.opacity(0.06)
                                  : BloomHerTheme.Colors.primaryRose.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                            .strokeBorder(
                                viewModel.codeEntryError != nil
                                    ? BloomHerTheme.Colors.error
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )

                // Error message
                if let error = viewModel.codeEntryError {
                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Image(BloomIcons.xmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text(error)
                            .font(BloomHerTheme.Typography.caption)
                    }
                    .foregroundStyle(BloomHerTheme.Colors.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                BloomButton(
                    "Join Session",
                    style: .primary,
                    icon: BloomIcons.checkmarkCircle,
                    isFullWidth: true
                ) {
                    viewModel.joinWithCode()
                }
                .disabled(viewModel.enteredCode.count < 6)
                .opacity(viewModel.enteredCode.count < 6 ? 0.5 : 1)
            }
            .padding(BloomHerTheme.Spacing.md)
            .animation(BloomHerTheme.Animation.quick, value: viewModel.codeEntryError)
        }
    }

    // MARK: - Steps

    private var stepsSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("How to Get a Code")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                let steps: [(String, String)] = [
                    ("Your partner opens BloomHer and taps Partner Sharing.", ""),
                    ("They tap 'Generate Share Code' to create a unique code.", ""),
                    ("They share the 6-character code with you.", ""),
                    ("Enter the code above to view their cycle phase and tips.", ""),
                ]
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Text("\(index + 1)")
                            .font(BloomHerTheme.Typography.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            .frame(width: 28, height: 28)
                            .background(BloomHerTheme.Colors.primaryRose.opacity(0.12), in: Circle())
                        Text(step.0)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Privacy Note

    private var privacyNote: some View {
        BloomCard {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.lockShield)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Privacy First")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("You'll only see phase summaries and support tips that your partner has chosen to share. Exact dates, health data, and journal entries remain private.")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview {
    PartnerCodeEntryView(dependencies: AppDependencies.preview())
}
