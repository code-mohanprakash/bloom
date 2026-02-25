//
//  PartnerViewModel.swift
//  BloomHer
//
//  Observable view-model for all Partner feature screens.
//  Manages share-code generation, active session state, phase-specific
//  partner tips, and the partner action log.
//

import Foundation
import Observation
import SwiftUI

// MARK: - Supporting Types

/// A single supportive action a partner can log.
struct LoggedAction: Identifiable, Codable {
    let id: UUID
    let title: String
    let icon: String
    let loggedAt: Date

    init(title: String, icon: String) {
        self.id       = UUID()
        self.title    = title
        self.icon     = icon
        self.loggedAt = Date()
    }
}

// MARK: - PartnerViewModel

/// Source of truth for all Partner feature screens.
@Observable
@MainActor
final class PartnerViewModel {

    // MARK: - Dependencies

    private let partnerService: PartnerSharingServiceProtocol
    private let cycleRepository: CycleRepositoryProtocol
    private let predictionService: CyclePredictorProtocol

    // MARK: - Partner Share State

    /// The active `PartnerShare` SwiftData record, or `nil` when not sharing.
    var partnerShare: PartnerShare?

    /// The most-recently generated or loaded share code.
    var shareCode: String?

    /// `true` when an active partner-sharing session exists.
    var isSharing: Bool { activeSession != nil }

    /// The active local share session managed by `PartnerSharingService`.
    private(set) var activeSession: PartnerShareSession?

    // MARK: - Shared Cycle State

    /// The cycle phase currently visible to the partner (nil when not sharing).
    var sharedPhase: CyclePhase? {
        guard isSharing else { return nil }
        return currentPhase
    }

    /// The internally computed current phase (used regardless of sharing state).
    var currentPhase: CyclePhase {
        guard
            let cycles = cycleData,
            let activeCycle = cycleRepository.fetchActiveCycle(),
            let prediction = cyclePrediction
        else { return .follicular }
        return predictionService.currentPhase(
            lastPeriodStart: activeCycle.startDate,
            prediction: prediction
        )
    }

    // MARK: - Partner Tips

    /// Phase-specific partner tips for the current cycle phase.
    var partnerTips: [PartnerTip] {
        PartnerEducationData.tips(for: currentPhase)
    }

    // MARK: - Action Log

    private static let actionLogKey = "bloomher.partnerActionLog"

    /// All logged supportive actions, sorted newest-first.
    var actionLog: [LoggedAction] = []

    /// Actions logged today.
    var todayActions: [LoggedAction] {
        actionLog.filter { Calendar.current.isDateInToday($0.loggedAt) }
    }

    /// Count of actions logged in the current ISO week.
    var actionsThisWeek: Int {
        let calendar = Calendar.current
        return actionLog.filter {
            calendar.isDate($0.loggedAt, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
    }

    // MARK: - UI State

    var showRevokeConfirmation = false
    var isLoading = false
    var errorMessage: String?

    // MARK: - Code Entry State

    var enteredCode: String = ""
    var codeEntryError: String?
    var joinedSession: PartnerShareSession?
    var hasJoined: Bool { joinedSession != nil }

    // MARK: - Privacy Toggles

    var sharesMood: Bool = true
    var sharesSymptoms: Bool = false
    var sharesPhaseInfo: Bool = true
    var sharesAppointments: Bool = false

    // MARK: - Private State

    private var cycleData: [CycleEntry]?
    private var cyclePrediction: CyclePrediction?

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.partnerService    = dependencies.partnerService
        self.cycleRepository   = dependencies.cycleRepository
        self.predictionService = dependencies.cyclePredictionService
    }

    // MARK: - Public API

    /// Loads partner session state and cycle data.
    func loadPartnerData() {
        isLoading = true
        let cycles = cycleRepository.fetchAllCycles()
        cycleData = cycles
        if !cycles.isEmpty {
            cyclePrediction = predictionService.predictNextPeriod(from: cycles)
        }
        let sessions = partnerService.fetchActiveSessions()
        activeSession = sessions.first
        if let session = activeSession {
            shareCode = session.shareCode
        }
        loadActionLog()
        isLoading = false
    }

    /// Generates a new share code and starts a sharing session.
    func generateShareCode() {
        let session = partnerService.activateSharing(partnerName: nil)
        activeSession = session
        shareCode     = session.shareCode
        BloomHerTheme.Haptics.success()
    }

    /// Revokes the current active sharing session.
    func revokeAccess() {
        guard let session = activeSession else { return }
        partnerService.deactivateSharing(sessionID: session.id)
        activeSession = nil
        shareCode     = nil
        BloomHerTheme.Haptics.medium()
    }

    /// Attempts to join a partner session using the entered code.
    func joinWithCode() {
        codeEntryError = nil
        let trimmed = enteredCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard trimmed.count == 6 else {
            codeEntryError = "Please enter a 6-character code."
            BloomHerTheme.Haptics.error()
            return
        }

        guard partnerService.validateShareCode(trimmed) else {
            codeEntryError = "Invalid code format. Check and try again."
            BloomHerTheme.Haptics.error()
            return
        }

        if let session = partnerService.joinWithCode(trimmed) {
            joinedSession = session
            activeSession = session
            shareCode = session.shareCode
            BloomHerTheme.Haptics.success()
        } else {
            codeEntryError = "No active session found for this code."
            BloomHerTheme.Haptics.error()
        }
    }

    /// Logs a supportive partner action and persists it.
    func logAction(_ action: LoggedAction) {
        actionLog.insert(action, at: 0)
        persistActionLog()
        BloomHerTheme.Haptics.success()
    }

    // MARK: - Action Log Persistence

    private func loadActionLog() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.actionLogKey),
            let decoded = try? JSONDecoder().decode([LoggedAction].self, from: data)
        else { return }
        actionLog = decoded
    }

    private func persistActionLog() {
        guard let data = try? JSONEncoder().encode(actionLog) else { return }
        UserDefaults.standard.set(data, forKey: Self.actionLogKey)
    }
}

