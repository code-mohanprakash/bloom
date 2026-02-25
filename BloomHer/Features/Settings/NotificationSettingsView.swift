//
//  NotificationSettingsView.swift
//  BloomHer
//
//  Notification preference controls: period reminder, pill reminder (with
//  time picker), water reminder interval, and appointment reminders.
//

import SwiftUI

// MARK: - NotificationSettingsView

/// Manages all notification toggles and scheduling preferences.
///
/// The master `notificationsEnabled` toggle gates all sub-options. When
/// disabled every individual toggle is grayed out and non-interactive.
/// Pill reminder time is controlled with a `DatePicker` in `.compact` mode.
struct NotificationSettingsView: View {

    // MARK: - Input

    @Bindable var settingsManager: SettingsManager

    // MARK: - Environment

    @Environment(AppDependencies.self) private var dependencies

    // MARK: - Local State

    /// Days-before stepper for the period reminder (1–7 days).
    @State private var periodReminderDaysBefore: Int = 2

    /// Water reminder interval index (0 = 1 hr, 1 = 2 hr, 2 = 3 hr).
    @State private var waterReminderIntervalIndex: Int = 1

    /// Whether appointment reminders are enabled (local only, not in SettingsManager).
    @State private var appointmentRemindersEnabled: Bool = false

    // MARK: - Body

    var body: some View {
        List {
            masterToggleSection
            if settingsManager.notificationsEnabled {
                periodReminderSection
                pillReminderSection
                waterReminderSection
                appointmentSection
            }
            tipsSection
        }
        .bloomBackground()
        .bloomNavigation("Notifications")
        .animation(BloomHerTheme.Animation.standard, value: settingsManager.notificationsEnabled)
        .onAppear {
            guard settingsManager.notificationsEnabled else { return }
            Task {
                let granted = await dependencies.notificationService.requestPermission()
                if granted {
                    scheduleAllEnabledReminders()
                }
            }
        }
        .onChange(of: settingsManager.notificationsEnabled) { _, isEnabled in
            if isEnabled {
                Task {
                    let granted = await dependencies.notificationService.requestPermission()
                    guard granted else {
                        settingsManager.notificationsEnabled = false
                        return
                    }
                    scheduleAllEnabledReminders()
                }
            } else {
                dependencies.notificationService.cancelAll()
            }
        }
        .onChange(of: settingsManager.periodReminderEnabled) { _, isEnabled in
            if isEnabled {
                schedulePeriodReminder()
            } else {
                dependencies.notificationService.cancelNotification(
                    identifier: NotificationIdentifier.periodReminderPrefix
                )
            }
        }
        .onChange(of: periodReminderDaysBefore) { _, _ in
            if settingsManager.periodReminderEnabled {
                schedulePeriodReminder()
            }
        }
        .onChange(of: settingsManager.pillReminderEnabled) { _, isEnabled in
            if isEnabled {
                schedulePillReminder()
            } else {
                dependencies.notificationService.cancelNotification(
                    identifier: NotificationIdentifier.pillReminderDaily
                )
            }
        }
        .onChange(of: settingsManager.pillReminderTime) { _, _ in
            if settingsManager.pillReminderEnabled {
                schedulePillReminder()
            }
        }
        .onChange(of: waterReminderIntervalIndex) { _, _ in
            if settingsManager.notificationsEnabled {
                scheduleWaterReminders()
            }
        }
    }

    // MARK: - Master Toggle

    private var masterToggleSection: some View {
        Section {
            Toggle(isOn: $settingsManager.notificationsEnabled) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    notifIcon(systemImage: BloomIcons.bell, color: BloomColors.accentPeach)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Allow BloomHer to send reminders")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Period Reminder Section

    private var periodReminderSection: some View {
        Section {
            Toggle(isOn: $settingsManager.periodReminderEnabled) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    notifIcon(systemImage: BloomIcons.drop, color: BloomColors.menstrual)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Period Reminder")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Alert before your predicted period")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)

            if settingsManager.periodReminderEnabled {
                HStack {
                    Text("Days before period")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Stepper(
                        "\(periodReminderDaysBefore) day\(periodReminderDaysBefore == 1 ? "" : "s")",
                        value: $periodReminderDaysBefore,
                        in: 1...7
                    )
                    .labelsHidden()
                    Text("\(periodReminderDaysBefore) day\(periodReminderDaysBefore == 1 ? "" : "s")")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        .frame(minWidth: 55, alignment: .trailing)
                }
                .listRowBackground(BloomHerTheme.Colors.surface)
            }
        } header: {
            sectionHeader("Period")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Pill Reminder Section

    private var pillReminderSection: some View {
        Section {
            Toggle(isOn: $settingsManager.pillReminderEnabled) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    notifIcon(systemImage: BloomIcons.pill, color: BloomColors.sageGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pill / Supplement Reminder")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Daily reminder to take supplements")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)

            if settingsManager.pillReminderEnabled {
                DatePicker(
                    "Reminder time",
                    selection: $settingsManager.pillReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .tint(BloomColors.primaryRose)
                .listRowBackground(BloomHerTheme.Colors.surface)
            }
        } header: {
            sectionHeader("Supplements")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Water Reminder Section

    private var waterReminderSection: some View {
        Section {
            let intervalLabels = ["Every hour", "Every 2 hours", "Every 3 hours"]
            Picker("Remind me", selection: $waterReminderIntervalIndex) {
                ForEach(intervalLabels.indices, id: \.self) { idx in
                    Text(intervalLabels[idx]).tag(idx)
                }
            }
            .pickerStyle(.menu)
            .font(BloomHerTheme.Typography.body)
            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Water Reminders")
        } footer: {
            Text("You'll receive gentle nudges throughout the day to stay hydrated.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Appointment Section

    private var appointmentSection: some View {
        Section {
            Toggle(isOn: $appointmentRemindersEnabled) {
                HStack(spacing: BloomHerTheme.Spacing.sm) {
                    notifIcon(systemImage: BloomIcons.stethoscope, color: BloomColors.accentLavender)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Appointment Reminders")
                            .font(BloomHerTheme.Typography.body)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text("Remind before health appointments")
                            .font(BloomHerTheme.Typography.footnote)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }
            }
            .tint(BloomColors.primaryRose)
            .listRowBackground(BloomHerTheme.Colors.surface)
        } header: {
            sectionHeader("Appointments")
        }
        .listRowSeparatorTint(BloomHerTheme.Colors.textTertiary.opacity(0.3))
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        Section {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                Image(BloomIcons.info)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(BloomColors.info)
                Text("You can manage notification permissions at any time in Settings > Notifications > BloomHer.")
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .listRowBackground(BloomColors.info.opacity(0.08))
        }
        .listRowSeparatorTint(Color.clear)
    }

    // MARK: - Scheduling

    private func scheduleAllEnabledReminders() {
        if settingsManager.periodReminderEnabled {
            schedulePeriodReminder()
        }
        if settingsManager.pillReminderEnabled {
            schedulePillReminder()
        }
        scheduleWaterReminders()
    }

    private func schedulePeriodReminder() {
        let cycles = dependencies.cycleRepository.fetchAllCycles()
        guard !cycles.isEmpty else { return }
        let prediction = dependencies.cyclePredictionService.predictNextPeriod(from: cycles)
        dependencies.notificationService.schedulePeriodReminder(
            predictedDate: prediction.predictedNextStart,
            daysBefore: periodReminderDaysBefore
        )
    }

    private func schedulePillReminder() {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: settingsManager.pillReminderTime
        )
        dependencies.notificationService.schedulePillReminder(time: components)
    }

    private func scheduleWaterReminders() {
        let intervals = [1, 2, 3]
        let safeIndex = min(max(waterReminderIntervalIndex, 0), intervals.count - 1)
        dependencies.notificationService.scheduleWaterReminder(intervalHours: intervals[safeIndex])
    }

    // MARK: - Helpers

    private func notifIcon(systemImage: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemImage)
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
}

// MARK: - Preview

#Preview("Notification Settings") {
    let deps = AppDependencies.preview()
    deps.settingsManager.notificationsEnabled = true
    deps.settingsManager.periodReminderEnabled = true
    deps.settingsManager.pillReminderEnabled = true
    return NavigationStack {
        NotificationSettingsView(settingsManager: deps.settingsManager)
    }
    .environment(deps)
}
