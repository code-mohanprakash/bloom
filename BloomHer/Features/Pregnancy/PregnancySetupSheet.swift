//
//  PregnancySetupSheet.swift
//  BloomHer
//
//  Sheet for initial pregnancy setup. Supports three input modes:
//  LMP date, known due date, and ultrasound + gestational age.
//

import SwiftUI

// MARK: - PregnancySetupSheet

struct PregnancySetupSheet: View {

    // MARK: State

    @Environment(\.dismiss) private var dismiss

    private let repository: PregnancyRepositoryProtocol

    @State private var selectedMode: Int = 0
    @State private var lmpDate: Date = Calendar.current.date(byAdding: .day, value: -70, to: Date()) ?? Date()
    @State private var knownDueDate: Date = Calendar.current.date(byAdding: .day, value: 210, to: Date()) ?? Date()
    @State private var ultrasoundDate: Date = Date()
    @State private var gestationalWeeks: Int = 12
    @State private var gestationalDays: Int = 0
    @State private var babyName: String = ""
    @State private var showConfirmation: Bool = false

    // MARK: Init

    init(repository: PregnancyRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Computed

    private var computedDueDate: Date {
        switch selectedMode {
        case 0:
            // LMP + 280 days
            return Calendar.current.date(byAdding: .day, value: 280, to: lmpDate) ?? lmpDate
        case 1:
            // Direct entry
            return knownDueDate
        case 2:
            // Ultrasound date — subtract gestational age then add 280
            let totalDays = gestationalWeeks * 7 + gestationalDays
            let lmpFromUltrasound = Calendar.current.date(byAdding: .day, value: -totalDays, to: ultrasoundDate) ?? ultrasoundDate
            return Calendar.current.date(byAdding: .day, value: 280, to: lmpFromUltrasound) ?? ultrasoundDate
        default:
            return knownDueDate
        }
    }

    private var computedLMP: Date {
        switch selectedMode {
        case 0:
            return lmpDate
        case 1:
            return Calendar.current.date(byAdding: .day, value: -280, to: knownDueDate) ?? knownDueDate
        case 2:
            let totalDays = gestationalWeeks * 7 + gestationalDays
            return Calendar.current.date(byAdding: .day, value: -totalDays, to: ultrasoundDate) ?? ultrasoundDate
        default:
            return lmpDate
        }
    }

    private var currentWeekPreview: Int {
        let days = Calendar.current.dateComponents([.day], from: computedLMP, to: Date()).day ?? 0
        return max(1, min(42, (days / 7) + 1))
    }

    private var dueDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: computedDueDate)
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.xl) {
                    headerIllustration
                    modeSelector
                    inputSection
                    previewCard
                    if !babyName.isEmpty || true {
                        babyNameField
                    }
                    saveButton
                }
                .padding(BloomHerTheme.Spacing.md)
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("Set Up Pregnancy")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
    }

    // MARK: - Header Illustration

    private var headerIllustration: some View {
        VStack(spacing: BloomHerTheme.Spacing.sm) {
            BloomFruitBaby(week: currentWeekPreview, size: 120)
                .animation(BloomHerTheme.Animation.gentle, value: currentWeekPreview)

            Text("Let's set up your pregnancy journey")
                .font(BloomHerTheme.Typography.title3)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Choose how you'd like to calculate your due date")
                .font(BloomHerTheme.Typography.subheadline)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, BloomHerTheme.Spacing.md)
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        BloomSegmentedControl(
            options: ["LMP", "Due Date", "Ultrasound"],
            selectedIndex: $selectedMode
        )
        .animation(BloomHerTheme.Animation.standard, value: selectedMode)
    }

    // MARK: - Input Section

    @ViewBuilder
    private var inputSection: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                switch selectedMode {
                case 0:
                    lmpInputSection
                case 1:
                    dueDateInputSection
                case 2:
                    ultrasoundInputSection
                default:
                    lmpInputSection
                }
            }
        }
    }

    private var lmpInputSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Last Menstrual Period")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Text("Enter the first day of your last period. We'll calculate your due date as 280 days from this date.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)

            BloomDatePicker(
                label: "LMP Date",
                date: $lmpDate,
                range: Calendar.current.date(byAdding: .year, value: -1, to: Date())!...Date()
            )
        }
    }

    private var dueDateInputSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Known Due Date")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Text("Enter your confirmed due date from your doctor or midwife.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)

            BloomDatePicker(
                label: "Due Date",
                date: $knownDueDate,
                range: Date()...Calendar.current.date(byAdding: .year, value: 1, to: Date())!
            )
        }
    }

    private var ultrasoundInputSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Text("Ultrasound Dating")
                .font(BloomHerTheme.Typography.headline)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

            Text("Enter the scan date and gestational age shown on your ultrasound report.")
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)

            BloomDatePicker(
                label: "Ultrasound Date",
                date: $ultrasoundDate,
                range: Calendar.current.date(byAdding: .year, value: -1, to: Date())!...Date()
            )

            HStack(spacing: BloomHerTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Weeks")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Picker("Weeks", selection: $gestationalWeeks) {
                        ForEach(4...42, id: \.self) { w in
                            Text("\(w)").tag(w)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .tint(BloomHerTheme.Colors.primaryRose)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    Text("Days")
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Picker("Days", selection: $gestationalDays) {
                        ForEach(0...6, id: \.self) { d in
                            Text("\(d)").tag(d)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .tint(BloomHerTheme.Colors.primaryRose)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(BloomHerTheme.Spacing.xs)
            .background(BloomHerTheme.Colors.background, in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium))
        }
    }

    // MARK: - Preview Card

    private var previewCard: some View {
        BloomCard {
            VStack(spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.pregTestStick)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    Text("Your Pregnancy Summary")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                }

                HStack(spacing: BloomHerTheme.Spacing.xl) {
                    summaryItem(label: "Due Date", value: dueDateFormatted)
                    summaryItem(label: "Current Week", value: "Week \(currentWeekPreview)")
                }

                // Glowing due date emphasis
                Text(dueDateFormatted)
                    .font(BloomHerTheme.Typography.title3)
                    .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BloomHerTheme.Spacing.sm)
                    .background(
                        BloomHerTheme.Colors.primaryRose.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium)
                    )
            }
        }
        .animation(BloomHerTheme.Animation.gentle, value: computedDueDate)
    }

    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: BloomHerTheme.Spacing.xxxs) {
            Text(value)
                .font(BloomHerTheme.Typography.title3)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            Text(label)
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Baby Name Field

    private var babyNameField: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                HStack {
                    Image(BloomIcons.pregBabyOnesie)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    Text("Baby's Name (Optional)")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                }
                TextField("Nickname or chosen name", text: $babyName)
                    .font(BloomHerTheme.Typography.body)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    .tint(BloomHerTheme.Colors.primaryRose)
                    .padding(BloomHerTheme.Spacing.sm)
                    .background(
                        BloomHerTheme.Colors.background,
                        in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.medium)
                    )
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        BloomButton("Start Tracking", style: .primary, icon: BloomIcons.heartFilled, isFullWidth: true) {
            saveProfile()
        }
    }

    // MARK: - Actions

    private func saveProfile() {
        let profile = PregnancyProfile(lmpDate: computedLMP)
        profile.dueDate = computedDueDate
        if !babyName.isEmpty {
            profile.babyName = babyName
        }
        repository.savePregnancy(profile)
        BloomHerTheme.Haptics.success()
        dismiss()
    }
}

// MARK: - Preview

#Preview("Pregnancy Setup") {
    PregnancySetupSheet(repository: PreviewPregnancyRepository())
}

// Internal preview repository
private class PreviewPregnancyRepository: PregnancyRepositoryProtocol {
    func fetchActivePregnancy() -> PregnancyProfile? { nil }
    func fetchAllPregnancies() -> [PregnancyProfile] { [] }
    func savePregnancy(_ pregnancy: PregnancyProfile) {}
    func deletePregnancy(_ pregnancy: PregnancyProfile) {}
    func fetchKickSessions(for pregnancy: PregnancyProfile) -> [KickSession] { [] }
    func saveKickSession(_ session: KickSession) {}
    func fetchContractions(for pregnancy: PregnancyProfile) -> [ContractionEntry] { [] }
    func saveContraction(_ contraction: ContractionEntry) {}
    func fetchWeightEntries(for pregnancy: PregnancyProfile) -> [WeightEntry] { [] }
    func saveWeightEntry(_ entry: WeightEntry) {}
    func fetchAppointments(for pregnancy: PregnancyProfile) -> [Appointment] { [] }
    func saveAppointment(_ appointment: Appointment) {}
    func deleteAppointment(_ appointment: Appointment) {}
}
