//
//  SupplementReminderView.swift
//  BloomHer
//
//  Supplement tracking and reminder screen.
//  Features:
//  • Toggle supplements on/off (Folic Acid, Prenatal, Iron, Vit D, Omega-3, Calcium, Magnesium)
//  • Reminder time picker per supplement
//  • Today's checklist (mark as taken with satisfying animation)
//  • Streak tracking per supplement
//  • Phase-specific recommendation cards
//  • Pregnancy recommendation card
//

import SwiftUI

// MARK: - Supplement Model

struct Supplement: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
    let defaultDose: String
    var isEnabled: Bool
    var isTakenToday: Bool
    var reminderTime: Date
    var streak: Int
    var phaseRecommendations: [CyclePhase]
    var isPregnancyRecommended: Bool

    static func == (lhs: Supplement, rhs: Supplement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - SupplementReminderView

struct SupplementReminderView: View {

    // MARK: State

    let phase: CyclePhase
    @State private var supplements: [Supplement] = Supplement.defaults
    @State private var showTimePicker: String? = nil
    @State private var selectedTime: Date = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: .now
    ) ?? .now
    @State private var showTakenAnimation: String? = nil

    @Environment(\.appMode) private var appMode

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                // Phase recommendation card
                phaseRecommendationCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 0)

                // Today's checklist
                if supplements.filter({ $0.isEnabled }).count > 0 {
                    todayChecklistSection
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                        .staggeredAppear(index: 1)
                }

                // All supplements management
                allSupplementsSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .staggeredAppear(index: 2)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Supplements")
        .sheet(item: Binding(
            get: { showTimePicker.flatMap { id in supplements.first { $0.id == id } } },
            set: { _ in showTimePicker = nil }
        )) { supplement in
            TimePickerSheet(supplement: supplement, selectedTime: $selectedTime) { time in
                updateReminderTime(supplementId: supplement.id, time: time)
                showTimePicker = nil
            }
            .bloomSheet()
        }
    }

    // MARK: - Phase Recommendation Card

    private var phaseRecommendationCard: some View {
        BloomCard(isPhaseAware: true) {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack(spacing: BloomHerTheme.Spacing.xs) {
                    Image(BloomIcons.starFilled)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("\(phase.displayName) Phase Recommendations")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }

                let phaseSupps = supplements.filter { $0.phaseRecommendations.contains(phase) }
                if phaseSupps.isEmpty {
                    Text("Maintain your regular supplement routine.")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(phaseSupps) { supp in
                            HStack(spacing: BloomHerTheme.Spacing.sm) {
                                Image(supp.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text(supp.name)
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                Spacer()
                                Text(supp.defaultDose)
                                    .font(BloomHerTheme.Typography.caption)
                                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            }
                        }
                    }
                }

                if appMode == .pregnant {
                    pregnancyNote
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
    }

    private var pregnancyNote: some View {
        HStack(spacing: BloomHerTheme.Spacing.xs) {
            Image(BloomIcons.heartFilled)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text("Folic Acid and Prenatal vitamins are especially important during pregnancy.")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .padding(BloomHerTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                .fill(BloomHerTheme.Colors.primaryRose.opacity(0.08))
        )
    }

    // MARK: - Today's Checklist

    private var todayChecklistSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            HStack {
                Text("Today's Supplements")
                    .font(BloomHerTheme.Typography.headline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                Spacer()
                let takenCount = supplements.filter { $0.isEnabled && $0.isTakenToday }.count
                let enabledCount = supplements.filter { $0.isEnabled }.count
                Text("\(takenCount) / \(enabledCount)")
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.sageGreen)
            }

            BloomProgressBar(
                progress: {
                    let enabled = supplements.filter { $0.isEnabled }
                    guard !enabled.isEmpty else { return 0 }
                    return Double(enabled.filter { $0.isTakenToday }.count) / Double(enabled.count)
                }(),
                color: BloomHerTheme.Colors.sageGreen,
                height: 8
            )

            VStack(spacing: BloomHerTheme.Spacing.xs) {
                ForEach(supplements.filter { $0.isEnabled }) { supplement in
                    ChecklistRow(
                        supplement: supplement,
                        showAnimation: showTakenAnimation == supplement.id,
                        onToggle: { toggleTaken(supplement) }
                    )
                }
            }
        }
    }

    // MARK: - All Supplements

    private var allSupplementsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Manage Supplements")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            VStack(spacing: BloomHerTheme.Spacing.sm) {
                ForEach($supplements) { $supplement in
                    SupplementManagementRow(
                        supplement: $supplement,
                        onReminderTap: {
                            selectedTime = supplement.reminderTime
                            showTimePicker = supplement.id
                        }
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleTaken(_ supplement: Supplement) {
        if let index = supplements.firstIndex(of: supplement) {
            supplements[index].isTakenToday.toggle()
            if supplements[index].isTakenToday {
                showTakenAnimation = supplement.id
                BloomHerTheme.Haptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showTakenAnimation = nil
                }
            } else {
                BloomHerTheme.Haptics.light()
            }
        }
    }

    private func updateReminderTime(supplementId: String, time: Date) {
        if let index = supplements.firstIndex(where: { $0.id == supplementId }) {
            supplements[index].reminderTime = time
        }
    }
}

// MARK: - ChecklistRow

private struct ChecklistRow: View {
    let supplement: Supplement
    let showAnimation: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: BloomHerTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(supplement.isTakenToday
                              ? BloomHerTheme.Colors.sageGreen
                              : BloomHerTheme.Colors.background)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    supplement.isTakenToday
                                    ? BloomHerTheme.Colors.sageGreen
                                    : BloomHerTheme.Colors.textTertiary,
                                    lineWidth: 1.5
                                )
                        )

                    if supplement.isTakenToday {
                        Image(BloomIcons.checkmark)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(BloomHerTheme.Animation.quick, value: supplement.isTakenToday)

                Image(supplement.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(supplement.name)
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text(supplement.defaultDose)
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                }

                Spacer()

                if supplement.streak > 0 {
                    HStack(spacing: BloomHerTheme.Spacing.xxxs) {
                        Image(BloomIcons.flame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("\(supplement.streak)d")
                            .font(BloomHerTheme.Typography.caption2)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                }

                // Particle burst overlay
                if showAnimation {
                    SparkleParticleView(color: BloomHerTheme.Colors.sageGreen, count: 6)
                        .frame(width: 40, height: 40)
                        .allowsHitTesting(false)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(BloomHerTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium, style: .continuous)
                    .fill(supplement.isTakenToday
                          ? BloomHerTheme.Colors.sageGreen.opacity(0.08)
                          : BloomHerTheme.Colors.surface)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(BloomHerTheme.Animation.standard, value: supplement.isTakenToday)
    }
}

// MARK: - SupplementManagementRow

private struct SupplementManagementRow: View {
    @Binding var supplement: Supplement
    let onReminderTap: () -> Void

    @State private var showDetails: Bool = false

    private var reminderFormatted: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: supplement.reminderTime)
    }

    var body: some View {
        BloomCard {
            VStack(spacing: 0) {
                // Header row
                HStack(spacing: BloomHerTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(supplement.color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(supplement.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }

                    VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                        Text(supplement.name)
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Text(supplement.description)
                            .font(BloomHerTheme.Typography.caption)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer()

                    Toggle("", isOn: $supplement.isEnabled)
                        .tint(supplement.color)
                }

                // Expanded details
                if supplement.isEnabled {
                    Divider()
                        .padding(.vertical, BloomHerTheme.Spacing.sm)

                    HStack {
                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxxs) {
                            Text("Daily Dose")
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                            Text(supplement.defaultDose)
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        }

                        Spacer()

                        Button {
                            onReminderTap()
                        } label: {
                            HStack(spacing: BloomHerTheme.Spacing.xxs) {
                                Image(BloomIcons.bell)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                Text(reminderFormatted)
                                    .font(BloomHerTheme.Typography.subheadline)
                                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                            }
                            .padding(.horizontal, BloomHerTheme.Spacing.sm)
                            .padding(.vertical, BloomHerTheme.Spacing.xxs)
                            .background(
                                Capsule()
                                    .fill(BloomHerTheme.Colors.primaryRose.opacity(0.12))
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .padding(BloomHerTheme.Spacing.md)
        }
        .animation(BloomHerTheme.Animation.standard, value: supplement.isEnabled)
    }
}

// MARK: - TimePickerSheet

private struct TimePickerSheet: View {
    let supplement: Supplement
    @Binding var selectedTime: Date
    let onSave: (Date) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: BloomHerTheme.Spacing.xl) {
                VStack(spacing: BloomHerTheme.Spacing.sm) {
                    Image(supplement.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    Text(supplement.name)
                        .font(BloomHerTheme.Typography.title2)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Text("Set your reminder time")
                        .font(BloomHerTheme.Typography.body)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                BloomButton("Save Reminder", style: .primary, icon: BloomIcons.bell, isFullWidth: true) {
                    BloomHerTheme.Haptics.success()
                    onSave(selectedTime)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.xl)
            }
            .padding(BloomHerTheme.Spacing.xl)
            .background(BloomHerTheme.Colors.background)
            .bloomNavigation("Set Reminder")
        }
    }
}

// MARK: - Default Supplements

extension Supplement {
    static let defaults: [Supplement] = [
        Supplement(
            id: "folic",
            name: "Folic Acid",
            icon: BloomIcons.pill,
            color: BloomHerTheme.Colors.primaryRose,
            description: "Neural tube health",
            defaultDose: "400 mcg/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [.follicular],
            isPregnancyRecommended: true
        ),
        Supplement(
            id: "prenatal",
            name: "Prenatal Vitamins",
            icon: BloomIcons.heartFilled,
            color: BloomHerTheme.Colors.primaryRose,
            description: "Comprehensive prenatal support",
            defaultDose: "1 tablet/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [],
            isPregnancyRecommended: true
        ),
        Supplement(
            id: "iron",
            name: "Iron",
            icon: BloomIcons.drop,
            color: BloomColors.menstrual,
            description: "Energy & blood health",
            defaultDose: "18 mg/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [.menstrual],
            isPregnancyRecommended: true
        ),
        Supplement(
            id: "vitd",
            name: "Vitamin D",
            icon: BloomIcons.sparkles,
            color: BloomHerTheme.Colors.accentPeach,
            description: "Hormones, immunity & mood",
            defaultDose: "1000-2000 IU/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [.follicular, .ovulation],
            isPregnancyRecommended: true
        ),
        Supplement(
            id: "omega3",
            name: "Omega-3",
            icon: BloomIcons.leaf,
            color: BloomColors.waterBlue,
            description: "Anti-inflammatory support",
            defaultDose: "1000-2000 mg/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [.menstrual, .luteal],
            isPregnancyRecommended: true
        ),
        Supplement(
            id: "calcium",
            name: "Calcium",
            icon: BloomIcons.bolt,
            color: BloomHerTheme.Colors.sageGreen,
            description: "Bone health & PMS relief",
            defaultDose: "500-1000 mg/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [.luteal],
            isPregnancyRecommended: true
        ),
        Supplement(
            id: "magnesium",
            name: "Magnesium",
            icon: BloomIcons.moonStars,
            color: BloomHerTheme.Colors.accentLavender,
            description: "Cramps, sleep & mood",
            defaultDose: "200-400 mg/day",
            isEnabled: false,
            isTakenToday: false,
            reminderTime: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: .now) ?? .now,
            streak: 0,
            phaseRecommendations: [.menstrual, .luteal],
            isPregnancyRecommended: false
        ),
    ]
}

// MARK: - Preview

#Preview("Supplement Reminders") {
    NavigationStack {
        SupplementReminderView(phase: .luteal)
    }
    .environment(\.currentCyclePhase, .luteal)
}
