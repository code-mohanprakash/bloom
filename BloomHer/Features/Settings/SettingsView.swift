//
//  SettingsView.swift
//  BloomHer
//
//  Main settings screen with grouped sections for profile, tracking
//  preferences, notifications, privacy, appearance, and about.
//

import SwiftUI
import SwiftData

// MARK: - SettingsView

/// The primary settings screen, presented as a `List` with grouped sections.
///
/// Each section uses `BloomCard` for the rows and `BloomHeader` for titles,
/// keeping the visual language consistent with the rest of the app. Destructive
/// or complex sub-screens are pushed via `NavigationLink`.
struct SettingsView: View {

    // MARK: - State

    @State private var viewModel: SettingsViewModel

    // MARK: - Environment

    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext

    // MARK: - Scaled Metrics

    @ScaledMetric(relativeTo: .body) private var iconBadgeSize: CGFloat = 32
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 22

    // MARK: - Init

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: SettingsViewModel(dependencies: dependencies))
    }

    // MARK: - Body

    var body: some View {
        List {
                accountSection.staggeredAppear(index: 0)
                profileSection.staggeredAppear(index: 1)
                trackingSection.staggeredAppear(index: 2)
                notificationsSection.staggeredAppear(index: 3)
                privacySection.staggeredAppear(index: 4)
                appearanceSection.staggeredAppear(index: 5)
                aboutSection.staggeredAppear(index: 6)
            }
            .bloomBackground()
            .bloomNavigation("Settings")
        .alert("Change Tracking Mode?", isPresented: $viewModel.showModeChangeConfirmation) {
            Button("Change", role: .destructive) { viewModel.confirmModeChange() }
            Button("Cancel", role: .cancel)      { viewModel.cancelModeChange() }
        } message: {
            Text("Switching mode changes your Home dashboard. Your existing data is preserved.")
        }
        .onChange(of: viewModel.feedbackMessage) { _, message in
            if message != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    viewModel.feedbackMessage = nil
                }
            }
        }
    }

    // MARK: - Account Section

    @ViewBuilder
    private var accountSection: some View {
        Section {
            SignInWithAppleView(authService: dependencies.authenticationService)
                .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            Text("Account")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
    }

    // MARK: - Profile Section

    @ViewBuilder
    private var profileSection: some View {
        Section {
            // Name field
            settingsRow(icon: BloomIcons.person, iconColor: BloomColors.primaryRose) {
                @Bindable var sm = viewModel.settingsManager
                HStack {
                    Text("Name")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    TextField("Your name", text: $sm.userName)
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            // App mode
            NavigationLink {
                AppModePickerView(viewModel: viewModel)
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.iconCycle,
                    iconColor: BloomColors.accentLavender,
                    title: "Tracking Mode",
                    value: appModeLabel(viewModel.settingsManager.appMode)
                )
            }

            NavigationLink {
                PartnerSetupView(dependencies: dependencies)
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.personPlus,
                    iconColor: BloomColors.sageGreen,
                    title: "Partner Sharing",
                    value: nil
                )
            }
        } header: {
            sectionHeader("Profile")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Tracking Section

    @ViewBuilder
    private var trackingSection: some View {
        @Bindable var sm = viewModel.settingsManager
        Section {
            // Cycle length and period length are irrelevant in pregnancy mode
            if viewModel.settingsManager.appMode != .pregnant {
                stepperRow(
                    icon: BloomIcons.calendar,
                    iconColor: BloomColors.menstrual,
                    title: "Default Cycle Length",
                    value: $sm.defaultCycleLength,
                    range: 21...45,
                    unit: "days"
                )
                stepperRow(
                    icon: BloomIcons.drop,
                    iconColor: BloomColors.menstrual,
                    title: "Default Period Length",
                    value: $sm.defaultPeriodLength,
                    range: 2...10,
                    unit: "days"
                )
            }
            stepperRow(
                icon: BloomIcons.hydration,
                iconColor: BloomColors.waterBlue,
                title: "Water Goal",
                value: $sm.waterGoalMl,
                range: 1000...4000,
                step: 100,
                unit: "ml"
            )
        } header: {
            sectionHeader("Tracking")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            NavigationLink {
                NotificationSettingsView(settingsManager: viewModel.settingsManager)
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.bell,
                    iconColor: BloomColors.accentPeach,
                    title: "Notifications",
                    value: viewModel.settingsManager.notificationsEnabled ? "On" : "Off"
                )
            }
        } header: {
            sectionHeader("Notifications")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        Section {
            NavigationLink {
                PrivacySettingsView(
                    viewModel: viewModel,
                    modelContext: modelContext
                )
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.lockShield,
                    iconColor: BloomColors.sageGreen,
                    title: "Privacy & Data",
                    value: nil
                )
            }

            NavigationLink {
                HealthKitSettingsView(viewModel: viewModel)
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.heartFilled,
                    iconColor: BloomColors.menstrual,
                    title: "Apple Health",
                    value: viewModel.healthKitConnected ? "Connected" : "Not connected"
                )
            }
        } header: {
            sectionHeader("Privacy & Data")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section {
            NavigationLink {
                AppearanceSettingsView(settingsManager: viewModel.settingsManager)
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.colorDropper,
                    iconColor: BloomColors.accentLavender,
                    title: "Appearance",
                    value: viewModel.settingsManager.selectedThemeMode.displayName
                )
            }

            settingsRow(icon: BloomIcons.pulse, iconColor: BloomColors.accentPeach) {
                @Bindable var sm = viewModel.settingsManager
                Toggle(isOn: $sm.hapticFeedbackEnabled) {
                    Text("Haptic Feedback")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }
                .tint(BloomColors.primaryRose)
            }
        } header: {
            sectionHeader("Appearance")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView(version: viewModel.versionString)
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.info,
                    iconColor: BloomColors.primaryRose,
                    title: "About BloomHer",
                    value: viewModel.appVersion
                )
            }

            NavigationLink {
                MedicalDisclaimerView()
            } label: {
                settingsRowLabel(
                    icon: BloomIcons.stethoscope,
                    iconColor: BloomColors.sageGreen,
                    title: "Medical Disclaimer",
                    value: nil
                )
            }
        } header: {
            sectionHeader("About")
        }
        .listRowBackground(BloomHerTheme.Colors.surface)
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Row Helpers

    private func settingsRow<Content: View>(
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            iconBadge(icon: icon, color: iconColor)
            content()
        }
    }

    private func settingsRowLabel(
        icon: String,
        iconColor: Color,
        title: String,
        value: String?
    ) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            iconBadge(icon: icon, color: iconColor)
            Text(title)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            Spacer()
            if let value {
                Text(value)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            }
        }
    }

    private func stepperRow(
        icon: String,
        iconColor: Color,
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int = 1,
        unit: String
    ) -> some View {
        HStack(spacing: BloomHerTheme.Spacing.sm) {
            iconBadge(icon: icon, color: iconColor)
            Text(title)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            Spacer()
            Stepper(
                "\(value.wrappedValue) \(unit)",
                value: value,
                in: range,
                step: step
            )
            .font(BloomHerTheme.Typography.body)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .labelsHidden()
            Text("\(value.wrappedValue) \(unit)")
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .frame(minWidth: 60, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(BloomHerTheme.Animation.quick, value: value.wrappedValue)
        }
    }

    private func iconBadge(icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: iconBadgeSize, height: iconBadgeSize)
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BloomHerTheme.Typography.footnote)
            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            .textCase(nil)
    }

    // MARK: - Mode Label

    private func appModeLabel(_ mode: AppMode) -> String {
        switch mode {
        case .cycle:    return "Cycle Tracking"
        case .pregnant: return "Pregnancy"
        case .ttc:      return "Trying to Conceive"
        }
    }
}

// MARK: - AppModePickerView

/// Inline sub-view for selecting the app's tracking mode.
private struct AppModePickerView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                ForEach(viewModel.appModeOptions, id: \.mode) { option in
                    Button {
                        viewModel.requestModeChange(to: option.mode)
                    } label: {
                        HStack(spacing: BloomHerTheme.Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(BloomColors.primaryRose.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                if let customIcon = modeCustomIcon(option.mode) {
                                    Image(customIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                } else {
                                    Image(option.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .font(BloomHerTheme.Typography.body)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                Text(option.subtitle)
                                    .font(BloomHerTheme.Typography.footnote)
                                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            }
                            Spacer()
                            if viewModel.settingsManager.appMode == option.mode {
                                Image(BloomIcons.checkmarkCircle)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(BloomColors.primaryRose)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(BloomHerTheme.Colors.surface)
                }
            } header: {
                Text("Select Mode")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .textCase(nil)
            }
        }
        .bloomBackground()
        .bloomNavigation("Tracking Mode")
        .alert("Change Tracking Mode?", isPresented: $viewModel.showModeChangeConfirmation) {
            Button("Change", role: .destructive) { viewModel.confirmModeChange() }
            Button("Cancel", role: .cancel)      { viewModel.cancelModeChange() }
        } message: {
            Text("Switching mode changes your Home dashboard. Your existing data is preserved.")
        }
    }

    private func modeCustomIcon(_ mode: AppMode) -> String? {
        switch mode {
        case .cycle:    return "icon-cycle"
        case .pregnant: return "iconpreg"
        case .ttc:      return "icon-ttc"
        }
    }
}

// MARK: - Preview

#Preview("Settings View") {
    let deps = AppDependencies.preview()
    return SettingsView(dependencies: deps)
        .environment(deps)
        .modelContainer(DataConfiguration.makeInMemoryContainer())
}
