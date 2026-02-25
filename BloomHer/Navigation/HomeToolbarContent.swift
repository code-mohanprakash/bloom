//
//  HomeToolbarContent.swift
//  BloomHer
//
//  Mode-specific toolbar rendered in the home tab's navigation bar.
//  Shows frosted-glass rounded-square buttons for AI chat, partner sharing,
//  a context-sensitive quick action, and the theme toggle.
//

import SwiftUI

// MARK: - HomeToolbarContent

struct HomeToolbarContent: ToolbarContent {

    // MARK: Dependencies

    let appMode: AppMode
    let settingsManager: SettingsManager
    let aiAvailable: Bool

    // MARK: Bindings

    @Binding var showAIChat: Bool
    @Binding var showPartnerSetup: Bool

    /// Mode-specific quick action binding (e.g. notifications, kick counter, OPK test).
    let onModeAction: () -> Void

    // MARK: Body

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack(spacing: BloomHerTheme.Spacing.xs) {
                // Ask Bloom — AI chat
                if aiAvailable {
                    toolbarButton(
                        icon: BloomIcons.dove,
                        label: "Ask Bloom"
                    ) {
                        BloomHerTheme.Haptics.medium()
                        showAIChat = true
                    }
                }

                // Partner sharing
                toolbarButton(
                    icon: BloomIcons.personPlus,
                    label: "Partner Sharing"
                ) {
                    BloomHerTheme.Haptics.light()
                    showPartnerSetup = true
                }

                // Mode-specific quick action
                toolbarButton(
                    icon: modeActionIcon,
                    label: modeActionLabel
                ) {
                    BloomHerTheme.Haptics.light()
                    onModeAction()
                }

                // Theme toggle
                ThemeToolbarButton(settingsManager: settingsManager)
            }
        }
    }

    // MARK: - Mode Action Config

    private var modeActionIcon: String {
        switch appMode {
        case .cycle:    return BloomIcons.bell
        case .pregnant: return BloomIcons.kickCounter
        case .ttc:      return BloomIcons.opkTest
        }
    }

    private var modeActionLabel: String {
        switch appMode {
        case .cycle:    return "Notifications"
        case .pregnant: return "Kick Counter"
        case .ttc:      return "OPK Test"
        }
    }

    // MARK: - Rounded-Square Button

    private static let buttonShape = RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)

    @ViewBuilder
    private func toolbarButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .frame(width: 34, height: 34)
                .background(.ultraThinMaterial, in: Self.buttonShape)
                .overlay(
                    Self.buttonShape
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(label)
    }
}

// MARK: - ThemeToolbarButton

/// Compact theme-cycle button for the toolbar.
/// Cycles Dark -> Light -> Auto on tap.
struct ThemeToolbarButton: View {

    let settingsManager: SettingsManager
    @State private var isAnimating = false

    private static let shape = RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small, style: .continuous)

    var body: some View {
        Button {
            BloomHerTheme.Haptics.selection()
            withAnimation(BloomHerTheme.Animation.quick) {
                isAnimating = true
                settingsManager.selectedThemeMode = settingsManager.selectedThemeMode.next
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isAnimating = false
            }
        } label: {
            Image(settingsManager.selectedThemeMode.icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(isAnimating ? 20 : 0))
                .foregroundStyle(.primary.opacity(0.75))
                .frame(width: 34, height: 34)
                .background(.ultraThinMaterial, in: Self.shape)
                .overlay(
                    Self.shape
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Change appearance: \(settingsManager.selectedThemeMode.shortLabel)")
        .animation(BloomHerTheme.Animation.quick, value: settingsManager.selectedThemeMode)
    }
}
