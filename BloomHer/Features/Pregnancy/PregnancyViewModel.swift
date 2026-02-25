//
//  PregnancyViewModel.swift
//  BloomHer
//
//  @Observable ViewModel for all pregnancy tracking screens.
//  Aggregates data from PregnancyRepositoryProtocol and exposes
//  computed properties for week, trimester, and due date countdown.
//

import Foundation
import SwiftUI

// MARK: - PregnancyViewModel

/// Observable ViewModel for all pregnancy tracking screens.
///
/// Fetches data lazily from `PregnancyRepositoryProtocol` and exposes
/// reactive computed properties for views to bind against.
@Observable
@MainActor
final class PregnancyViewModel {

    // MARK: - Repository

    private let repository: PregnancyRepositoryProtocol

    // MARK: - Published State

    var pregnancyProfile: PregnancyProfile?
    var recentKickSessions: [KickSession] = []
    var recentContractions: [ContractionEntry] = []
    var weightEntries: [WeightEntry] = []
    var upcomingAppointments: [Appointment] = []
    var showSetup: Bool = false

    // MARK: - Computed Properties

    var currentWeek: Int {
        pregnancyProfile?.currentWeek ?? 1
    }

    var daysUntilDue: Int {
        pregnancyProfile?.daysUntilDue ?? 0
    }

    var trimester: Int {
        pregnancyProfile?.trimester ?? 1
    }

    var todaysKickCount: Int {
        let calendar = Calendar.current
        return recentKickSessions
            .filter { calendar.isDateInToday($0.startTime) }
            .reduce(0) { $0 + $1.kickCount }
    }

    var latestWeight: Double? {
        weightEntries.last?.weightKg
    }

    var pregnancyProgress: Double {
        guard currentWeek > 0 else { return 0 }
        return min(Double(currentWeek) / 40.0, 1.0)
    }

    var trimesterLabel: String {
        switch trimester {
        case 1: return "First Trimester"
        case 2: return "Second Trimester"
        default: return "Third Trimester"
        }
    }

    var dueDateFormatted: String {
        guard let profile = pregnancyProfile else { return "Not set" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: profile.dueDate)
    }

    // MARK: - Init

    init(repository: PregnancyRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func refresh() {
        pregnancyProfile = repository.fetchActivePregnancy()
        guard let profile = pregnancyProfile else {
            showSetup = true
            return
        }
        showSetup = false
        loadKickSessions(for: profile)
        loadContractions(for: profile)
        loadWeightHistory(for: profile)
        loadAppointments(for: profile)
    }

    func loadKickSessions() {
        guard let profile = pregnancyProfile else { return }
        loadKickSessions(for: profile)
    }

    func loadContractions() {
        guard let profile = pregnancyProfile else { return }
        loadContractions(for: profile)
    }

    func loadWeightHistory() {
        guard let profile = pregnancyProfile else { return }
        loadWeightHistory(for: profile)
    }

    func loadAppointments() {
        guard let profile = pregnancyProfile else { return }
        loadAppointments(for: profile)
    }

    func saveKickSession(_ session: KickSession) {
        repository.saveKickSession(session)
        loadKickSessions()
    }

    func saveContraction(_ contraction: ContractionEntry) {
        repository.saveContraction(contraction)
        loadContractions()
    }

    func saveWeightEntry(_ entry: WeightEntry) {
        repository.saveWeightEntry(entry)
        loadWeightHistory()
    }

    func saveAppointment(_ appointment: Appointment) {
        repository.saveAppointment(appointment)
        loadAppointments()
    }

    func deleteAppointment(_ appointment: Appointment) {
        repository.deleteAppointment(appointment)
        loadAppointments()
    }

    func createProfile(lmpDate: Date, dueDate: Date? = nil) {
        let profile = PregnancyProfile(lmpDate: lmpDate)
        if let customDueDate = dueDate {
            profile.dueDate = customDueDate
        }
        repository.savePregnancy(profile)
        refresh()
    }

    // MARK: - Private Loaders

    private func loadKickSessions(for profile: PregnancyProfile) {
        recentKickSessions = Array(
            repository.fetchKickSessions(for: profile).prefix(10)
        )
    }

    private func loadContractions(for profile: PregnancyProfile) {
        recentContractions = Array(
            repository.fetchContractions(for: profile).prefix(20)
        )
    }

    private func loadWeightHistory(for profile: PregnancyProfile) {
        weightEntries = repository.fetchWeightEntries(for: profile)
    }

    private func loadAppointments(for profile: PregnancyProfile) {
        let all = repository.fetchAppointments(for: profile)
        upcomingAppointments = all.filter { !$0.isCompleted && $0.date >= Date() }
    }
}
