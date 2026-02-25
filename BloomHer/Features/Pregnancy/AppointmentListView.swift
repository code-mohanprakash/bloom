//
//  AppointmentListView.swift
//  BloomHer
//
//  Appointment management screen with upcoming/past sections,
//  add appointment sheet, NHS schedule suggestions, and reminder toggles.
//

import SwiftUI

// MARK: - AppointmentListView

struct AppointmentListView: View {

    // MARK: State

    @State private var viewModel: PregnancyViewModel
    @State private var showAddAppointment: Bool = false
    @State private var showPastAppointments: Bool = false

    // MARK: Init

    init(viewModel: PregnancyViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: Computed

    private var allAppointments: [Appointment] {
        guard let profile = viewModel.pregnancyProfile else { return [] }
        // Using the full list from the profile relationship
        return profile.appointments.sorted { $0.date < $1.date }
    }

    private var upcomingAppointments: [Appointment] {
        allAppointments.filter { !$0.isCompleted && $0.date >= Date() }
    }

    private var pastAppointments: [Appointment] {
        allAppointments.filter { $0.isCompleted || $0.date < Date() }
    }

    private var nextAppointment: Appointment? {
        upcomingAppointments.first
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xl) {
                if let next = nextAppointment {
                    nextAppointmentHero(next)
                        .padding(.horizontal, BloomHerTheme.Spacing.md)
                }

                upcomingSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                nhsScheduleCard
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                pastAppointmentsSection
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
            }
            .padding(.top, BloomHerTheme.Spacing.lg)
            .padding(.bottom, BloomHerTheme.Spacing.xxxl)
        }
        .bloomBackground()
        .bloomNavigation("Appointments")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    BloomHerTheme.Haptics.light()
                    showAddAppointment = true
                } label: {
                    Image(BloomIcons.plusCircle)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }
        }
        .sheet(isPresented: $showAddAppointment, onDismiss: {
            viewModel.loadAppointments()
        }) {
            AddAppointmentSheet(viewModel: viewModel)
                .bloomSheet()
        }
        .task {
            viewModel.loadAppointments()
        }
    }

    // MARK: - Next Appointment Hero

    private func nextAppointmentHero(_ appointment: Appointment) -> some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.calendarClock)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Next Appointment")
                        .font(BloomHerTheme.Typography.subheadline)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    Spacer()
                    daysUntilBadge(appointment.date)
                }

                Text(appointment.title)
                    .font(BloomHerTheme.Typography.title2)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                HStack(spacing: BloomHerTheme.Spacing.md) {
                    Label {
                        Text(appointment.date.formatted(.dateTime.weekday(.wide).day().month()))
                    } icon: {
                        Image(BloomIcons.calendar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                    Label {
                        Text(appointment.date.formatted(.dateTime.hour().minute()))
                    } icon: {
                        Image(BloomIcons.clock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }

                if let location = appointment.location, !location.isEmpty {
                    Label {
                        Text(location)
                    } icon: {
                        Image(BloomIcons.mapPin)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                    .font(BloomHerTheme.Typography.footnote)
                    .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
        .staggeredAppear(index: 0)
    }

    private func daysUntilBadge(_ date: Date) -> some View {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return Text(days == 0 ? "Today" : "In \(days)d")
            .font(BloomHerTheme.Typography.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, BloomHerTheme.Spacing.xs)
            .padding(.vertical, BloomHerTheme.Spacing.xxxs)
            .background(days <= 3 ? BloomHerTheme.Colors.primaryRose : BloomHerTheme.Colors.accentLavender, in: Capsule())
    }

    // MARK: - Upcoming Section

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            BloomHeader(title: "Upcoming") {
                Button {
                    BloomHerTheme.Haptics.light()
                    showAddAppointment = true
                } label: {
                    Image(BloomIcons.plus)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(BloomHerTheme.Colors.primaryRose)
                }
            }

            if upcomingAppointments.isEmpty {
                BloomCard {
                    HStack {
                        Image(BloomIcons.calendarPlus)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("No upcoming appointments")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(upcomingAppointments) { appointment in
                        AppointmentRow(
                            appointment: appointment,
                            isNext: appointment.id == nextAppointment?.id,
                            onComplete: {
                                appointment.isCompleted = true
                                viewModel.saveAppointment(appointment)
                                viewModel.loadAppointments()
                            },
                            onDelete: {
                                viewModel.deleteAppointment(appointment)
                            }
                        )
                    }
                }
            }
        }
        .staggeredAppear(index: 1)
    }

    // MARK: - NHS Schedule Card

    private var nhsScheduleCard: some View {
        BloomCard {
            VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                HStack {
                    Image(BloomIcons.firstAid)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Recommended Schedule")
                        .font(BloomHerTheme.Typography.headline)
                        .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                    Spacer()
                    Text("NHS")
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, BloomHerTheme.Spacing.xs)
                        .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                        .background(BloomColors.info, in: Capsule())
                }

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                    ForEach(NHSScheduleItem.allItems) { item in
                        nhsScheduleRow(item)
                    }
                }
            }
        }
        .staggeredAppear(index: 2)
    }

    private func nhsScheduleRow(_ item: NHSScheduleItem) -> some View {
        let isCompleted = (viewModel.pregnancyProfile?.currentWeek ?? 0) > item.week
        return HStack(spacing: BloomHerTheme.Spacing.sm) {
            Text("Wk \(item.week)")
                .font(BloomHerTheme.Typography.caption)
                .foregroundStyle(.white)
                .frame(width: 40)
                .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                .background(isCompleted ? BloomHerTheme.Colors.sageGreen : BloomColors.info, in: Capsule())

            VStack(alignment: .leading, spacing: 0) {
                Text(item.title)
                    .font(BloomHerTheme.Typography.subheadline)
                    .foregroundStyle(isCompleted ? BloomHerTheme.Colors.textSecondary : BloomHerTheme.Colors.textPrimary)
                    .strikethrough(isCompleted)
                Text(item.detail)
                    .font(BloomHerTheme.Typography.caption)
                    .foregroundStyle(BloomHerTheme.Colors.textTertiary)
            }

            Spacer()

            if isCompleted {
                Image(BloomIcons.checkmarkCircle)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(BloomHerTheme.Colors.sageGreen)
            }
        }
    }

    // MARK: - Past Appointments

    private var pastAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
            Button {
                withAnimation(BloomHerTheme.Animation.standard) {
                    showPastAppointments.toggle()
                }
                BloomHerTheme.Haptics.light()
            } label: {
                HStack {
                    BloomHeader(title: "Past Appointments", subtitle: "\(pastAppointments.count) completed")
                    Spacer()
                    Image(showPastAppointments ? BloomIcons.chevronUp : BloomIcons.chevronDown)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if showPastAppointments {
                if pastAppointments.isEmpty {
                    BloomCard {
                        Text("No past appointments")
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                    }
                } else {
                    VStack(spacing: BloomHerTheme.Spacing.xs) {
                        ForEach(pastAppointments) { appointment in
                            AppointmentRow(
                                appointment: appointment,
                                isNext: false,
                                onComplete: nil,
                                onDelete: {
                                    viewModel.deleteAppointment(appointment)
                                }
                            )
                        }
                    }
                }
            }
        }
        .staggeredAppear(index: 3)
    }
}

// MARK: - AppointmentRow

private struct AppointmentRow: View {
    let appointment: Appointment
    let isNext: Bool
    let onComplete: (() -> Void)?
    let onDelete: () -> Void

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: appointment.date)
    }

    var body: some View {
        BloomCard {
            HStack(alignment: .top, spacing: BloomHerTheme.Spacing.sm) {
                // Category accent
                RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                    .fill(isNext ? BloomHerTheme.Colors.primaryRose : BloomHerTheme.Colors.accentLavender)
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
                    HStack {
                        Text(appointment.title)
                            .font(BloomHerTheme.Typography.headline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                        Spacer()
                        if isNext {
                            Text("Next")
                                .font(BloomHerTheme.Typography.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, BloomHerTheme.Spacing.xs)
                                .padding(.vertical, BloomHerTheme.Spacing.xxxs)
                                .background(BloomHerTheme.Colors.primaryRose, in: Capsule())
                        }
                    }

                    Text(dateFormatted)
                        .font(BloomHerTheme.Typography.footnote)
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)

                    if let location = appointment.location, !location.isEmpty {
                        Label {
                            Text(location)
                        } icon: {
                            Image(BloomIcons.mapPin)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                        }
                        .font(BloomHerTheme.Typography.caption)
                        .foregroundStyle(BloomHerTheme.Colors.textTertiary)
                    }
                }

                VStack(spacing: BloomHerTheme.Spacing.xs) {
                    if let complete = onComplete {
                        Button(action: complete) {
                            Image(BloomIcons.checkmark)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(BloomHerTheme.Colors.sageGreen)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }

                    Button(action: onDelete) {
                        Image(BloomIcons.trash)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(BloomHerTheme.Colors.error)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}

// MARK: - AddAppointmentSheet

struct AddAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: PregnancyViewModel
    @State private var title: String = ""
    @State private var date: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @State private var location: String = ""
    @State private var doctorName: String = ""
    @State private var notes: String = ""
    @State private var enableReminder: Bool = true
    @State private var reminderMinutes: Int = 60

    init(viewModel: PregnancyViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BloomHerTheme.Spacing.lg) {
                    Image(BloomIcons.calendarPlus)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .padding(.top, BloomHerTheme.Spacing.xl)

                    BloomCard {
                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.md) {
                            Text("Appointment Details")
                                .font(BloomHerTheme.Typography.headline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                            fieldRow(label: "Title", placeholder: "e.g. 20-week scan", text: $title)
                            fieldRow(label: "Doctor / Midwife", placeholder: "Name (optional)", text: $doctorName)
                            fieldRow(label: "Location", placeholder: "Hospital or clinic name", text: $location)
                        }
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    BloomCard {
                        BloomDatePicker(
                            label: "Date & Time",
                            date: $date,
                            displayedComponents: [.date, .hourAndMinute],
                            range: Date()...Calendar.current.date(byAdding: .year, value: 1, to: Date())!
                        )
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    BloomCard {
                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.sm) {
                            Toggle(isOn: $enableReminder) {
                                Label {
                                    Text("Reminder")
                                } icon: {
                                    Image(BloomIcons.bell)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                }
                                .font(BloomHerTheme.Typography.subheadline)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                            }
                            .tint(BloomHerTheme.Colors.primaryRose)

                            if enableReminder {
                                Picker("Remind me", selection: $reminderMinutes) {
                                    Text("15 minutes before").tag(15)
                                    Text("30 minutes before").tag(30)
                                    Text("1 hour before").tag(60)
                                    Text("1 day before").tag(1440)
                                }
                                .pickerStyle(.menu)
                                .tint(BloomHerTheme.Colors.primaryRose)
                                .font(BloomHerTheme.Typography.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    BloomCard {
                        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xs) {
                            Label {
                                Text("Notes")
                            } icon: {
                                Image(BloomIcons.note)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                            }
                            .font(BloomHerTheme.Typography.subheadline)
                            .foregroundStyle(BloomHerTheme.Colors.textPrimary)

                            TextField("Questions to ask, things to bring...", text: $notes, axis: .vertical)
                                .font(BloomHerTheme.Typography.body)
                                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                                .tint(BloomHerTheme.Colors.primaryRose)
                                .lineLimit(3...6)
                        }
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)

                    BloomButton("Save Appointment", style: .primary, icon: BloomIcons.checkmark, isFullWidth: true) {
                        saveAppointment()
                    }
                    .padding(.horizontal, BloomHerTheme.Spacing.md)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                }
                .padding(.bottom, BloomHerTheme.Spacing.xxxl)
            }
            .bloomBackground()
            .bloomNavigation("New Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(BloomHerTheme.Colors.textSecondary)
                }
            }
        }
    }

    private func fieldRow(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: BloomHerTheme.Spacing.xxs) {
            Text(label)
                .font(BloomHerTheme.Typography.footnote)
                .foregroundStyle(BloomHerTheme.Colors.textSecondary)
            TextField(placeholder, text: text)
                .font(BloomHerTheme.Typography.body)
                .foregroundStyle(BloomHerTheme.Colors.textPrimary)
                .tint(BloomHerTheme.Colors.primaryRose)
                .padding(BloomHerTheme.Spacing.xs)
                .background(
                    BloomHerTheme.Colors.background,
                    in: RoundedRectangle(cornerRadius: BloomHerTheme.Radius.small)
                )
        }
    }

    private func saveAppointment() {
        let appointment = Appointment(title: title.trimmingCharacters(in: .whitespaces), date: date)
        appointment.pregnancy = viewModel.pregnancyProfile
        if !location.isEmpty { appointment.location = location }
        if !notes.isEmpty { appointment.notes = notes }
        if enableReminder { appointment.reminderMinutesBefore = reminderMinutes }
        viewModel.saveAppointment(appointment)
        BloomHerTheme.Haptics.success()
        dismiss()
    }
}

// MARK: - NHSScheduleItem

private struct NHSScheduleItem: Identifiable {
    let id = UUID()
    let week: Int
    let title: String
    let detail: String

    static let allItems: [NHSScheduleItem] = [
        NHSScheduleItem(week: 8,  title: "Booking Appointment", detail: "First midwife visit, blood tests, urine"),
        NHSScheduleItem(week: 12, title: "Dating Scan", detail: "First ultrasound + nuchal translucency"),
        NHSScheduleItem(week: 16, title: "Midwife Appointment", detail: "Blood pressure, urine, results review"),
        NHSScheduleItem(week: 18, title: "Whooping Cough Vaccine", detail: "Offered between 16–32 weeks"),
        NHSScheduleItem(week: 20, title: "Anomaly Scan", detail: "Detailed structural scan of baby"),
        NHSScheduleItem(week: 25, title: "Midwife Appointment", detail: "Growth check, glucose screening"),
        NHSScheduleItem(week: 28, title: "Midwife Appointment", detail: "Anti-D if Rh negative, blood tests"),
        NHSScheduleItem(week: 31, title: "Midwife Appointment", detail: "Growth check, birth plan discussion"),
        NHSScheduleItem(week: 34, title: "Midwife Appointment", detail: "Finalise birth plan, GBS discussion"),
        NHSScheduleItem(week: 36, title: "Midwife Appointment", detail: "Position check, hospital bag check"),
        NHSScheduleItem(week: 38, title: "Midwife Appointment", detail: "Pre-labour assessment"),
        NHSScheduleItem(week: 40, title: "Due Date Appointment", detail: "Post-dates discussion if not birthed"),
    ]
}

// MARK: - Preview

#Preview("Appointment List") {
    NavigationStack {
        AppointmentListView(viewModel: PregnancyViewModel(repository: PreviewApptRepo()))
    }
}

#Preview("Add Appointment") {
    AddAppointmentSheet(viewModel: PregnancyViewModel(repository: PreviewApptRepo()))
}

private class PreviewApptRepo: PregnancyRepositoryProtocol {
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
