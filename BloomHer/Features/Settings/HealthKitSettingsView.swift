//
//  HealthKitSettingsView.swift
//  BloomHer
//
//  Apple Health integration screen: shows connection status, the list of
//  data types synced, and provides a connect/disconnect action.
//

import SwiftUI

// MARK: - HealthKitSettingsView

/// Manages the Apple Health (HealthKit) connection for BloomHer.
///
/// Surfaces connection status, lists the data categories that are read from
/// or written to HealthKit, and provides a "Connect" button that requests
/// system authorisation. The button is hidden when HealthKit is unavailable
/// on the current device.
struct HealthKitSettingsView: View {

    // MARK: - Input

    @Bindable var viewModel: SettingsViewModel

    // MARK: - Body

    var body: some View {
        List {
            statusSection
            if viewModel.healthKitAvailable {
                dataTypesSection
                actionSection
            } else {
                unavailableSection
            }
        }
        .bloomBackground()
        .bloomNavigation("Apple Health")
        .onChange(of: viewModel.feedbackMessage) { _, msg in
            if msg != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    viewModel.feedbackMessage = nil
                }
            }
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        Section {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                // Health icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FF2D55"), Color(hex: "#FF6B81")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(BloomIcons.heartFilled)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Apple Health")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    HStack(spacing: BloomHerTheme.Spacing.xxs) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(statusLabel)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, BloomHerTheme.Spacing.xs)
            .listRowBackground(BloomHerTheme.Colors.surface)
        } footer: {
            if let msg = viewModel.feedbackMessage {
                Text(msg)
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomColors.sageGreen)
                    .transition(.opacity)
            }
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Data Types Section

    private var dataTypesSection: some View {
        Section {
            ForEach(healthKitDataTypes, id: \.title) { item in
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(item.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(item.permission)
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                    Spacer()
                    Text(item.direction)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                        .padding(.horizontal, BloomHerTheme.Spacing.xs)
                        .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                        .background(
                            Capsule().fill(BloomHerTheme.Colors.textTertiary.opacity(0.12))
                        )
                }
                .listRowBackground(BloomHerTheme.Colors.surface)
            }
        } header: {
            sectionHeader("Data Synced")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Action Section

    private var actionSection: some View {
        Section {
            if viewModel.healthKitConnected {
                // Already connected — show a note
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(BloomIcons.checkmarkCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(BloomColors.sageGreen)
                    Text("BloomHer is connected to Apple Health. Manage permissions in the Health app.")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .listRowBackground(BloomColors.sageGreen.opacity(0.08))
            } else {
                BloomButton(
                    "Connect to Apple Health",
                    style: .primary,
                    icon: BloomIcons.heart,
                    isFullWidth: true
                ) {
                    Task { await viewModel.connectHealthKit() }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(
                    top: BloomHerTheme.Spacing.sm,
                    leading: BloomHerTheme.Spacing.md,
                    bottom: BloomHerTheme.Spacing.sm,
                    trailing: BloomHerTheme.Spacing.md
                ))
            }
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Unavailable Section

    private var unavailableSection: some View {
        Section {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.errorCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(BloomColors.warning)
                Text("Apple Health is not available on this device. It requires an iPhone with the Health app.")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .listRowBackground(BloomColors.warning.opacity(0.08))
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Helpers

    private var statusColor: Color {
        guard viewModel.healthKitAvailable else { return BloomHerTheme.Colors.textTertiary }
        return viewModel.healthKitConnected ? BloomColors.sageGreen : BloomColors.warning
    }

    private var statusLabel: String {
        guard viewModel.healthKitAvailable else { return "Not available on this device" }
        return viewModel.healthKitConnected ? "Connected" : "Not connected"
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BloomHerTheme.Typography.footnote)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .textCase(nil)
    }

    // MARK: - Data Type Descriptors

    private struct HealthKitDataType {
        let icon:       String
        let title:      String
        let permission: String
        let direction:  String   // "Read", "Write", or "Read & Write"
    }

    private let healthKitDataTypes: [HealthKitDataType] = [
        HealthKitDataType(
            icon:       BloomIcons.drop,
            title:      "Menstrual Flow",
            permission: "Period start dates and flow level",
            direction:  "Read & Write"
        ),
        HealthKitDataType(
            icon:       BloomIcons.thermometer,
            title:      "Basal Body Temperature",
            permission: "Morning temperature readings",
            direction:  "Write"
        ),
        HealthKitDataType(
            icon:       BloomIcons.moonStars,
            title:      "Sleep Analysis",
            permission: "Sleep duration and quality",
            direction:  "Read"
        ),
        HealthKitDataType(
            icon:       BloomIcons.yoga,
            title:      "Workouts",
            permission: "Yoga and wellness sessions",
            direction:  "Write"
        )
    ]
}

// MARK: - Preview

#Preview("HealthKit Settings — Not Connected") {
    let deps = AppDependencies.preview()
    return NavigationStack {
        HealthKitSettingsView(viewModel: SettingsViewModel(dependencies: deps))
    }
    .environment(deps)
}
