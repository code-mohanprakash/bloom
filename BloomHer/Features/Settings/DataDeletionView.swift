//
//  DataDeletionView.swift
//  BloomHer
//
//  Two-step destructive data deletion screen. Warns clearly, requires
//  explicit confirmation, and provides visual feedback after deletion.
//

import SwiftUI
import SwiftData

// MARK: - DataDeletionView

/// Presents a clear warning and gated confirmation before deleting all health data.
///
/// The deletion flow is intentionally multi-step:
/// 1. User reads the warning and consequences list.
/// 2. User taps the danger button.
/// 3. A system `.confirmationDialog` (ActionSheet) asks for a final confirmation.
/// 4. On confirmation, `viewModel.deleteAllData` executes.
/// 5. Success state replaces the content.
struct DataDeletionView: View {

    // MARK: - Input

    @Bindable var viewModel: SettingsViewModel
    let modelContext: ModelContext

    // MARK: - Navigation

    @Environment(\.dismiss) private var dismiss

    // MARK: - Local State

    @State private var showConfirmationDialog: Bool = false
    @State private var deletionComplete: Bool = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                if deletionComplete {
                    successState
                } else {
                    warningHeader
                    consequencesList
                    actionArea
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .frame(maxWidth: .infinity)
        }
        .bloomBackground()
        .bloomNavigation("Delete All Data")
        .confirmationDialog(
            "Delete All Health Data?",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                performDeletion()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes all cycle logs, symptoms, water intake, and health records. This cannot be undone.")
        }
    }

    // MARK: - Warning Header

    private var warningHeader: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(BloomColors.menstrual.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(BloomIcons.trash)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(BloomColors.menstrual)
            }

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                Text("Delete All Health Data")
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This action is permanent and cannot be reversed.")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomColors.menstrual)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, BloomHerTheme.Spacing.lg)
    }

    // MARK: - Consequences List

    private var consequencesList: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("What will be deleted:")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                ForEach(deletionConsequences, id: \.self) { item in
                    HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                        Image(BloomIcons.xmarkCircle)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(BloomColors.menstrual)
                            .padding(.top, 2)
                        Text(item)
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Divider()
                    .background(BloomHerTheme.Colors.textTertiary.opacity(0.3))

                HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                    Image(BloomIcons.checkmarkCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(BloomColors.sageGreen)
                        .padding(.top, 2)
                    Text("Your app settings and preferences will be reset to defaults.")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    // MARK: - Action Area

    private var actionArea: some View {
        VStack(spacing: BloomHerTheme.Spacing.md) {
            if viewModel.isDeletingData {
                ProgressView("Clearing your garden…")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .tint(BloomColors.primaryRose)
                    .frame(maxWidth: .infinity)
                    .padding(BloomHerTheme.Spacing.lg)
            } else {
                BloomButton(
                    "Delete All Health Data",
                    style: .danger,
                    icon: BloomIcons.trash,
                    isFullWidth: true
                ) {
                    showConfirmationDialog = true
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel — Keep My Data")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, BloomHerTheme.Spacing.sm)
    }

    // MARK: - Success State

    private var successState: some View {
        VStack(spacing: BloomHerTheme.Spacing.xl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(BloomColors.sageGreen.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(BloomIcons.checkmarkCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(BloomColors.sageGreen)
            }
            VStack(spacing: BloomHerTheme.Spacing.sm) {
                Text("Data Deleted")
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Text("All your health data has been permanently removed from this device.")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            BloomButton("Done", style: .primary, isFullWidth: true) {
                dismiss()
            }
            Spacer()
        }
        .padding(.horizontal, BloomHerTheme.Spacing.lg)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Deletion Handler

    private func performDeletion() {
        viewModel.deleteAllData(modelContext: modelContext)
        withAnimation(BloomHerTheme.Animation.standard) {
            deletionComplete = true
        }
        BloomHerTheme.Haptics.success()
    }

    // MARK: - Consequences Data

    private let deletionConsequences: [String] = [
        "All menstrual cycle records and start/end dates",
        "Daily logs including moods, symptoms, and flow data",
        "Water intake history and tracking records",
        "Pregnancy profiles and associated records",
        "Yoga and wellness session history",
        "BBT (Basal Body Temperature) entries",
        "OPK test results and fertility records"
    ]
}

// MARK: - Preview

#Preview("Data Deletion View") {
    let deps = AppDependencies.preview()
    let container = DataConfiguration.makeInMemoryContainer()
    return NavigationStack {
        DataDeletionView(
            viewModel:    SettingsViewModel(dependencies: deps),
            modelContext: container.mainContext
        )
    }
    .environment(deps)
    .modelContainer(container)
}
