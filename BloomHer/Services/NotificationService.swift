import Foundation
import UserNotifications

// MARK: - NotificationServiceProtocol

protocol NotificationServiceProtocol {
    /// Requests the user's permission to display notifications.
    /// Returns true when permission is granted.
    func requestPermission() async -> Bool

    /// Schedules a period-prediction reminder `daysBefore` days before `predictedDate`.
    func schedulePeriodReminder(predictedDate: Date, daysBefore: Int)

    /// Schedules a repeating daily pill/supplement reminder at `time`.
    func schedulePillReminder(time: DateComponents)

    /// Schedules a one-off appointment reminder `minutesBefore` minutes before `date`.
    func scheduleAppointmentReminder(_ title: String, date: Date, minutesBefore: Int)

    /// Schedules repeating water-intake reminder notifications every `intervalHours` hours
    /// during waking hours (07:00–22:00).
    func scheduleWaterReminder(intervalHours: Int)

    /// Cancels all pending and delivered BloomHer notifications.
    func cancelAll()

    /// Cancels a single notification by its identifier.
    func cancelNotification(identifier: String)
}

// MARK: - Notification Identifiers

enum NotificationIdentifier {
    static let periodReminderPrefix    = "bloomher.period.reminder"
    static let pillReminderDaily       = "bloomher.pill.daily"
    static let appointmentPrefix       = "bloomher.appointment"
    static let waterReminderPrefix     = "bloomher.water"

    static func appointmentID(title: String, date: Date) -> String {
        "\(appointmentPrefix).\(title.hash).\(Int(date.timeIntervalSince1970))"
    }

    static func waterID(hour: Int) -> String {
        "\(waterReminderPrefix).\(hour)"
    }
}

// MARK: - Notification Category Identifiers

private enum NotificationCategory {
    static let period      = "BLOOMHER_PERIOD"
    static let pill        = "BLOOMHER_PILL"
    static let appointment = "BLOOMHER_APPOINTMENT"
    static let water       = "BLOOMHER_WATER"
}

// MARK: - NotificationService

/// Concrete implementation of `NotificationServiceProtocol` using `UNUserNotificationCenter`.
///
/// All scheduling is done via calendar-trigger or time-interval triggers.
/// Identifiers are deterministic so that re-scheduling overwrites stale requests
/// rather than accumulating duplicates.
final class NotificationService: NotificationServiceProtocol {

    // MARK: - Properties

    private let center: UNUserNotificationCenter

    // MARK: - Init

    init() {
        self.center = UNUserNotificationCenter.current()
        registerCategories()
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Period Reminder

    func schedulePeriodReminder(predictedDate: Date, daysBefore: Int) {
        guard daysBefore > 0 else { return }
        guard let reminderDate = Calendar.current.date(
            byAdding: .day, value: -daysBefore, to: predictedDate
        ) else { return }

        // Do not schedule a reminder in the past.
        guard reminderDate > Date() else { return }

        let content           = UNMutableNotificationContent()
        content.title         = "Your period is coming up"
        content.body          = "Your next period is predicted to start in \(daysBefore) day\(daysBefore == 1 ? "" : "s"). Take care of yourself today."
        content.sound         = .default
        content.categoryIdentifier = NotificationCategory.period

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger   = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request   = UNNotificationRequest(
            identifier: NotificationIdentifier.periodReminderPrefix,
            content:    content,
            trigger:    trigger
        )

        center.add(request)
    }

    // MARK: - Pill Reminder

    func schedulePillReminder(time: DateComponents) {
        // Remove existing daily pill reminder before re-scheduling.
        center.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.pillReminderDaily])

        let content           = UNMutableNotificationContent()
        content.title         = "Time for your supplement"
        content.body          = "Don't forget to take your vitamins or medication today."
        content.sound         = .default
        content.categoryIdentifier = NotificationCategory.pill

        // Extract only hour + minute for daily repetition.
        var triggerComponents        = DateComponents()
        triggerComponents.hour       = time.hour
        triggerComponents.minute     = time.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.pillReminderDaily,
            content:    content,
            trigger:    trigger
        )

        center.add(request)
    }

    // MARK: - Appointment Reminder

    func scheduleAppointmentReminder(_ title: String, date: Date, minutesBefore: Int) {
        guard let fireDate = Calendar.current.date(
            byAdding: .minute, value: -minutesBefore, to: date
        ) else { return }

        guard fireDate > Date() else { return }

        let content           = UNMutableNotificationContent()
        content.title         = "Upcoming appointment"
        content.body          = "\(title) is in \(minutesBefore) minute\(minutesBefore == 1 ? "" : "s")."
        content.sound         = .default
        content.categoryIdentifier = NotificationCategory.appointment

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger   = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id        = NotificationIdentifier.appointmentID(title: title, date: date)
        let request   = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - Water Reminder

    func scheduleWaterReminder(intervalHours: Int) {
        guard intervalHours > 0 else { return }

        // Cancel existing water reminders before scheduling fresh ones.
        cancelWaterReminders()

        // Schedule reminders between 07:00 and 22:00.
        let wakingHours = stride(from: 7, through: 22, by: intervalHours)

        for hour in wakingHours {
            let content           = UNMutableNotificationContent()
            content.title         = "Stay hydrated"
            content.body          = "Remember to drink some water — your body will thank you."
            content.sound         = .default
            content.categoryIdentifier = NotificationCategory.water

            var components  = DateComponents()
            components.hour = hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id      = NotificationIdentifier.waterID(hour: hour)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            center.add(request)
        }
    }

    // MARK: - Cancel

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    // MARK: - Private Helpers

    private func cancelWaterReminders() {
        let ids = (7...22).map { NotificationIdentifier.waterID(hour: $0) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Registers notification action categories.  Must be called once at startup.
    private func registerCategories() {
        let periodCategory = UNNotificationCategory(
            identifier:       NotificationCategory.period,
            actions:          [],
            intentIdentifiers: [],
            options:          []
        )
        let pillCategory = UNNotificationCategory(
            identifier:       NotificationCategory.pill,
            actions:          [],
            intentIdentifiers: [],
            options:          []
        )
        let appointmentCategory = UNNotificationCategory(
            identifier:       NotificationCategory.appointment,
            actions:          [],
            intentIdentifiers: [],
            options:          []
        )
        let waterCategory = UNNotificationCategory(
            identifier:       NotificationCategory.water,
            actions:          [],
            intentIdentifiers: [],
            options:          []
        )

        center.setNotificationCategories([
            periodCategory,
            pillCategory,
            appointmentCategory,
            waterCategory
        ])
    }
}
