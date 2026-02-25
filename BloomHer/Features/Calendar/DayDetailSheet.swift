//
//  DayDetailSheet.swift
//  BloomHer
//
//  A scrollable modal sheet for logging all daily health data for a selected
//  calendar date. Sections are wrapped in BloomCards with BloomHeaders.
//  A Save button at the bottom triggers a success haptic and dismisses.
//

import SwiftUI

// MARK: - DayDetailSheet

/// A full-featured daily logging sheet presented as a modal over the calendar.
///
/// Sections:
/// 1. Date header with phase badge
/// 2. Flow (intensity + colour)
/// 3. Mood
/// 4. Symptoms
/// 5. Cramps
/// 6. Energy
/// 7. Sleep
/// 8. Discharge
/// 9. Notes
/// 10. Save / period-action buttons
struct DayDetailSheet: View {

    // MARK: State

    @State var viewModel: DayDetailViewModel

    // MARK: Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currentCyclePhase) private var phase

    // MARK: Init

    init(viewModel: DayDetailViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.md) {
                    // Date header
                    dateHeader

                    // Flow section
                    flowSection

                    // Mood section
                    moodSection

                    // Symptoms section
                    symptomsSection

                    // Cramps section
                    crampsSection

                    // Energy section
                    energySection

                    // Sleep section
                    sleepSection

                    // Discharge section
                    dischargeSection

                    // Notes section
                    notesSection

                    // Period actions
                    periodActionsSection

                    // Save button
                    saveButton
                        .padding(.bottom, BloomHerTheme.Spacing.xl)
                }
                .padding(.horizontal, BloomHerTheme.Spacing.md)
                .padding(.top, BloomHerTheme.Spacing.sm)
            }
            .bloomBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    .font(BloomHerTheme.Typography.body)
                }
            }
        }
    }

    // MARK: Date Header

    private var dateHeader: some View {
        VStack(spacing: BloomHerTheme.Spacing.xs) {
            Text(formattedDate)
                .font(BloomHerTheme.Typography.title2)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: BloomHerTheme.Spacing.xs) {
                phaseBadge
                Spacer()
            }
        }
        .padding(.top, BloomHerTheme.Spacing.xs)
    }

    private var phaseBadge: some View {
        HStack(spacing: BloomHerTheme.Spacing.xxs + 2) {
            Image(phase.customImage ?? BloomIcons.phaseMenstrual)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text(phase.displayName)
                .font(BloomHerTheme.Typography.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, BloomHerTheme.Spacing.sm)
        .padding(.vertical, BloomHerTheme.Spacing.xxs)
        .background(Capsule().fill(BloomColors.color(for: phase)))
    }

    // MARK: Section: Flow

    private var flowSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Flow", subtitle: "Intensity & colour")

                FlowSelector(selected: Binding(
                    get: { viewModel.flowIntensity },
                    set: { viewModel.flowIntensity = $0 }
                ))
                .padding(.horizontal, -BloomHerTheme.Spacing.md)

                if viewModel.flowIntensity != nil {
                    Divider().background(BloomHerTheme.Colors.textTertiary.opacity(0.3))

                    FlowColourSelector(selected: Binding(
                        get: { viewModel.flowColour },
                        set: { viewModel.flowColour = $0 }
                    ))
                }
            }
        }
    }

    // MARK: Section: Mood

    private var moodSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Mood")

                MoodSelector(selected: Binding(
                    get: { viewModel.selectedMoods },
                    set: { viewModel.selectedMoods = $0 }
                ))
            }
        }
    }

    // MARK: Section: Symptoms

    private var symptomsSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Symptoms")

                SymptomSelector(selected: Binding(
                    get: { viewModel.selectedSymptoms },
                    set: { viewModel.selectedSymptoms = $0 }
                ))
            }
        }
    }

    // MARK: Section: Cramps

    private var crampsSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Cramps")

                CrampIntensitySelector(selected: Binding(
                    get: { viewModel.crampIntensity },
                    set: { viewModel.crampIntensity = $0 }
                ))
            }
        }
    }

    // MARK: Section: Energy

    private var energySection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Energy")

                EnergyLevelSelector(value: Binding(
                    get: { viewModel.energyLevel },
                    set: { viewModel.energyLevel = $0 }
                ))
            }
        }
    }

    // MARK: Section: Sleep

    private var sleepSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Sleep")

                SleepLogger(
                    hours: Binding(
                        get: { viewModel.sleepHours },
                        set: { viewModel.sleepHours = $0 }
                    ),
                    quality: Binding(
                        get: { viewModel.sleepQuality },
                        set: { viewModel.sleepQuality = $0 }
                    )
                )
            }
        }
    }

    // MARK: Section: Discharge

    private var dischargeSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Discharge")

                DischargeSelector(selected: Binding(
                    get: { viewModel.dischargeType },
                    set: { viewModel.dischargeType = $0 }
                ))
                .padding(.horizontal, -BloomHerTheme.Spacing.md)
            }
        }
    }

    // MARK: Section: Notes

    private var notesSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                BloomHeader(title: "Notes")

                BloomTextEditor(
                    placeholder: "How are you feeling today? Any observations…",
                    text: Binding(
                        get: { viewModel.notes },
                        set: { viewModel.notes = $0 }
                    ),
                    minHeight: 90
                )
            }
        }
    }

    // MARK: Section: Period Actions

    @ViewBuilder
    private var periodActionsSection: some View {
        if viewModel.date.startOfDay <= Date().startOfDay {
            BloomCard {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                    BloomHeader(title: "Period", subtitle: "Track cycle start or end")

                    HStack(spacing: BloomHerTheme.Spacing.sm) {
                        BloomButton(
                            "Period Start",
                            style: .outline,
                            size: .small,
                            icon: BloomIcons.drop,
                            isFullWidth: true
                        ) {
                            viewModel.startPeriod()
                        }

                        BloomButton(
                            "Period End",
                            style: .ghost,
                            size: .small,
                            icon: BloomIcons.checkmark,
                            isFullWidth: true
                        ) {
                            viewModel.endPeriod()
                        }
                    }
                }
            }
        }
    }

    // MARK: Save Button

    private var saveButton: some View {
        BloomButton(
            "Save",
            style: .primary,
            size: .large,
            icon: BloomIcons.checkmark,
            isFullWidth: true
        ) {
            viewModel.save()
            BloomHerTheme.Haptics.success()
            dismiss()
        }
    }

    // MARK: Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.locale = .current
        return formatter.string(from: viewModel.date)
    }
}

// MARK: - Preview

#Preview("Day Detail Sheet") {
    let deps = AppDependencies.preview()
    let vm = DayDetailViewModel(
        date: Date(),
        cycleRepository: deps.cycleRepository
    )
    return DayDetailSheet(viewModel: vm)
        .environment(deps)
        .environment(\.currentCyclePhase, .follicular)
}
