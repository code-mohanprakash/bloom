//
//  DayDetailViewModel.swift
//  BloomHer
//
//  Observable view-model for the day-detail logging sheet.
//  Fetches or creates the DailyLog for the given date, exposes all loggable
//  properties as mutable computed properties, tracks whether unsaved changes
//  exist, and persists on demand via save().
//

import Foundation

// MARK: - DayDetailViewModel

/// The `@Observable` view-model that drives `DayDetailSheet`.
///
/// Initialised with a date and repository, it immediately fetches or creates
/// the corresponding `DailyLog`. Every loggable property is surfaced as a
/// `get set` computed property that also sets `hasChanges = true` on mutation
/// so the UI can gate the Save button.
@Observable
final class DayDetailViewModel {

    // MARK: - Stored Properties

    /// The calendar day this view-model represents.
    let date: Date

    /// Tracks whether any property has been changed since initialisation or last save.
    var hasChanges: Bool = false

    // MARK: - Private

    private var dailyLog: DailyLog
    private let cycleRepository: CycleRepositoryProtocol

    // MARK: - Init

    init(date: Date, cycleRepository: CycleRepositoryProtocol) {
        self.date = date
        self.cycleRepository = cycleRepository
        self.dailyLog = cycleRepository.fetchOrCreateDailyLog(for: date)
    }

    // MARK: - DailyLog Property Accessors

    /// The logged menstrual flow intensity.
    var flowIntensity: FlowLevel? {
        get { dailyLog.flowIntensity }
        set { dailyLog.flowIntensity = newValue; hasChanges = true }
    }

    /// The observed menstrual flow colour.
    var flowColour: FlowColour? {
        get { dailyLog.flowColour }
        set { dailyLog.flowColour = newValue; hasChanges = true }
    }

    /// The set of moods logged for this day.
    var selectedMoods: Set<Mood> {
        get { Set(dailyLog.moods) }
        set { dailyLog.moods = Array(newValue); hasChanges = true }
    }

    /// The set of physical symptoms logged for this day.
    var selectedSymptoms: Set<Symptom> {
        get { Set(dailyLog.symptoms) }
        set { dailyLog.symptoms = Array(newValue); hasChanges = true }
    }

    /// The severity of cramping reported for this day.
    var crampIntensity: CrampLevel? {
        get { dailyLog.crampIntensity }
        set { dailyLog.crampIntensity = newValue; hasChanges = true }
    }

    /// The self-reported energy level (1–5).
    var energyLevel: Int? {
        get { dailyLog.energyLevel }
        set { dailyLog.energyLevel = newValue; hasChanges = true }
    }

    /// The number of hours slept (0–16, supports 0.5-hour increments).
    var sleepHours: Double? {
        get { dailyLog.sleepHours }
        set { dailyLog.sleepHours = newValue; hasChanges = true }
    }

    /// The self-reported sleep quality (1–5 stars).
    var sleepQuality: Int? {
        get { dailyLog.sleepQuality }
        set { dailyLog.sleepQuality = newValue; hasChanges = true }
    }

    /// Free-text notes for the day.
    var notes: String {
        get { dailyLog.notes ?? "" }
        set { dailyLog.notes = newValue.isEmpty ? nil : newValue; hasChanges = true }
    }

    /// The observed cervical discharge type.
    var dischargeType: DischargeType? {
        get { dailyLog.dischargeType }
        set { dailyLog.dischargeType = newValue; hasChanges = true }
    }

    /// Sexual activity or libido state logged for this day.
    var sexualActivity: SexualActivity? {
        get { dailyLog.sexualActivity }
        set { dailyLog.sexualActivity = newValue; hasChanges = true }
    }

    /// The set of skin conditions observed for this day.
    var selectedSkinConditions: Set<SkinCondition> {
        get { Set(dailyLog.skinConditions) }
        set { dailyLog.skinConditions = Array(newValue); hasChanges = true }
    }

    // MARK: - Actions

    /// Persists the current `DailyLog` state to the repository.
    ///
    /// After saving, `hasChanges` is reset to `false`.
    func save() {
        cycleRepository.saveDailyLog(dailyLog)
        hasChanges = false
    }

    /// Marks this date as the start of a new period cycle.
    ///
    /// Creates a new `CycleEntry` anchored to this date and immediately saves
    /// the associated daily log.
    func startPeriod() {
        let entry = CycleEntry(startDate: date.startOfDay, isConfirmed: true)
        cycleRepository.saveCycle(entry)
        dailyLog.cycleEntry = entry
        flowIntensity = flowIntensity ?? .medium
        save()
    }

    /// Marks this date as the end of the most-recent active cycle entry.
    ///
    /// Finds the active (open) `CycleEntry` and sets its `endDate` to this
    /// date, then persists the change.
    func endPeriod() {
        guard let activeCycle = cycleRepository.fetchActiveCycle() else { return }
        activeCycle.endDate = date.startOfDay
        cycleRepository.saveCycle(activeCycle)
        save()
    }
}
