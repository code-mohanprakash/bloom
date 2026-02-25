//
//  PrivacySettingsView.swift
//  BloomHer
//
//  Privacy & data management screen.
//  Controls iCloud sync, Apple Health connection, and the "Delete All Data"
//  destructive flow.
//

import SwiftUI
import SwiftData

// MARK: - PrivacySettingsView

/// Privacy controls — iCloud sync, Apple Health, and data deletion.
///
/// The delete flow is two-step: tapping the button sets
/// `viewModel.showDeleteConfirmation = true`, which triggers a destructive
/// confirmation alert. Only on explicit confirmation does `deleteAllData`
/// execute against the SwiftData `ModelContext`.
struct PrivacySettingsView: View {

    // MARK: - Input

    @Bindable var viewModel: SettingsViewModel
    let modelContext: ModelContext

    // MARK: - Body

    var body: some View {
        List {
            iCloudSection
            privacyPromiseSection
            legalSection
            deletionSection
        }
        .bloomBackground()
        .bloomNavigation("Privacy & Data")
        .alert("Delete All Data?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete Everything", role: .destructive) {
                viewModel.deleteAllData(modelContext: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes all your cycle logs, symptoms, and health data from this device. This action cannot be undone.")
        }
    }

    // MARK: - iCloud Section

    @ViewBuilder
    private var iCloudSection: some View {
        @Bindable var sm = viewModel.settingsManager
        Section {
            Toggle(isOn: $sm.iCloudSyncEnabled) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    iCloudIcon
                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud Sync")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Keep your data encrypted on iCloud")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)

            if sm.iCloudSyncEnabled {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(BloomIcons.checkmarkShield)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(BloomColors.sageGreen)
                    Text("Your data is encrypted end-to-end in iCloud. Apple cannot read it.")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .listRowBackground(BloomColors.sageGreen.opacity(0.08))
            }
        } header: {
            sectionHeader("Sync")
        } footer: {
            Text("Changing iCloud sync requires restarting the app to take effect.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Privacy Promise Section

    private var privacyPromiseSection: some View {
        Section {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                ForEach(privacyPromises, id: \.icon) { promise in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Image(promise.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(promise.title)
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            Text(promise.detail)
                                .font(BloomHerTheme.Typography.footnote)
                                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.vertical, BloomHerTheme.Spacing.xs)
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Our Privacy Promise")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        Section {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(BloomColors.sageGreen.opacity(0.12))
                            .frame(width: 30, height: 30)
                        Image(BloomIcons.document)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                    Text("Privacy Policy")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                }
            }
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Legal")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Deletion Section

    private var deletionSection: some View {
        Section {
            NavigationLink {
                DataDeletionView(viewModel: viewModel, modelContext: modelContext)
            } label: {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(BloomColors.menstrual)
                            .frame(width: 30, height: 30)
                        Image(BloomIcons.trash)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(.white)
                    }
                    Text("Delete All Health Data")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomColors.menstrual)
                    Spacer()
                }
            }
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Danger Zone")
        } footer: {
            Text("Permanently removes all cycle logs, symptoms, and health data from this device.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Helpers

    private var iCloudIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color(hex: "#3B82F6"))
                .frame(width: 30, height: 30)
            Image(BloomIcons.icloud)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(.white)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BloomHerTheme.Typography.footnote)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .textCase(nil)
    }

    // MARK: - Privacy Promises Data

    private struct PrivacyPromise {
        let icon: String
        let title: String
        let detail: String
    }

    private let privacyPromises: [PrivacyPromise] = [
        PrivacyPromise(
            icon:   BloomIcons.icloud,
            title:  "On-device first",
            detail: "All your health data is stored on your device by default. It never leaves without your explicit consent."
        ),
        PrivacyPromise(
            icon:   BloomIcons.checkmarkShield,
            title:  "No ads, no selling data",
            detail: "BloomHer does not sell, share, or monetise your personal health information."
        ),
        PrivacyPromise(
            icon:   BloomIcons.lockShield,
            title:  "End-to-end encrypted sync",
            detail: "When iCloud sync is enabled, data is encrypted before it leaves your device."
        )
    ]
}

// MARK: - Preview

#Preview("Privacy Settings") {
    let deps = AppDependencies.preview()
    let container = DataConfiguration.makeInMemoryContainer()
    return NavigationStack {
        PrivacySettingsView(
            viewModel:    SettingsViewModel(dependencies: deps),
            modelContext: container.mainContext
        )
    }
    .environment(deps)
    .modelContainer(container)
}
