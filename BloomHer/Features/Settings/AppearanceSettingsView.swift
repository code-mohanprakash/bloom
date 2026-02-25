//
//  AppearanceSettingsView.swift
//  BloomHer
//
//  Appearance preferences: theme mode picker (System / Light / Dark)
//  with a live preview card, plus the haptic feedback toggle.
//

import SwiftUI

// MARK: - AppearanceSettingsView

/// Controls the app's visual theme and haptic feedback preference.
///
/// Uses `BloomSegmentedControl` for the System / Light / Dark mode picker.
/// A `ThemePreviewCard` below the picker updates in real time to illustrate
/// how the selected theme will look.
struct AppearanceSettingsView: View {

    // MARK: - Input

    @Bindable var settingsManager: SettingsManager

    // MARK: - Local State

    @State private var selectedModeIndex: Int = 0

    // MARK: - Body

    var body: some View {
        List {
            themeSection
            previewSection
            hapticSection
        }
        .bloomBackground()
        .bloomNavigation("Appearance")
        .onAppear {
            selectedModeIndex = ThemeMode.allCases.firstIndex(of: settingsManager.selectedThemeMode) ?? 0
        }
        .onChange(of: selectedModeIndex) { _, newIndex in
            let newMode = ThemeMode.allCases[newIndex]
            settingsManager.selectedThemeMode = newMode
            BloomHerTheme.Haptics.selection()
        }
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        Section {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                Text("Color Scheme")
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                BloomSegmentedControl(
                    options:       ThemeMode.allCases.map(\.displayName),
                    selectedIndex: $selectedModeIndex
                )
                .background(
                    RoundedRectangle(cornerRadius: BloomHerTheme.Radius.pill, style: .continuous)
                        .fill(BloomHerTheme.Colors.background)
                )
            }
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Theme")
        } footer: {
            Text("System follows your device's appearance setting. Changes take effect immediately.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        Section {
            ThemePreviewCard(mode: settingsManager.selectedThemeMode)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(
                    top: BloomHerTheme.Spacing.xs,
                    leading: BloomHerTheme.Spacing.md,
                    bottom: BloomHerTheme.Spacing.xs,
                    trailing: BloomHerTheme.Spacing.md
                ))
        } header: {
            sectionHeader("Preview")
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Haptic Section

    private var hapticSection: some View {
        Section {
            Toggle(isOn: $settingsManager.hapticFeedbackEnabled) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(BloomColors.accentPeach)
                            .frame(width: 30, height: 30)
                        Image(BloomIcons.pulse)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptic Feedback")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Subtle vibrations on interactions")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Interactions")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Helper

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BloomHerTheme.Typography.footnote)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .textCase(nil)
    }
}

// MARK: - ThemePreviewCard

/// A mini mock card that illustrates what the selected theme looks like.
private struct ThemePreviewCard: View {

    let mode: ThemeMode

    var body: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            // Fake navigation bar
            HStack {
                Text("BloomHer")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Spacer()
                Circle()
                    .fill(BloomColors.primaryRose)
                    .frame(width: 24, height: 24)
            }
            Divider()
                .background(BloomHerTheme.Colors.textTertiary.opacity(0.3))

            // Fake content rows
            ForEach(0..<3) { _ in
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(BloomColors.primaryRose.opacity(0.3))
                        .frame(width: 32, height: 32)
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(BloomHerTheme.Colors.textPrimary.opacity(0.25))
                            .frame(width: 120, height: 10)
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(BloomHerTheme.Colors.textSecondary.opacity(0.2))
                            .frame(width: 80, height: 8)
                    }
                    Spacer()
                }
            }

            // Fake pill button
            HStack {
                Spacer()
                Text("Log Today")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(.white)
                    .padding(.horizontal, BloomHerTheme.Spacing.lg)
                    .padding(.vertical, BloomHerTheme.Spacing.xs)
                    .background(BloomColors.primaryRose)
                    .clipShape(Capsule())
                Spacer()
            }
        }
        .padding(BloomHerTheme.Spacing.md)
        .background(BloomHerTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.large, style: .continuous)
                .strokeBorder(BloomHerTheme.Colors.textTertiary.opacity(0.15), lineWidth: 1)
        )
        .preferredColorScheme(mode.colorScheme)
        .animation(BloomHerTheme.Animation.standard, value: mode)
    }
}

// MARK: - Preview

#Preview("Appearance Settings") {
    let deps = AppDependencies.preview()
    return NavigationStack {
        AppearanceSettingsView(settingsManager: deps.settingsManager)
    }
    .environment(deps)
}
