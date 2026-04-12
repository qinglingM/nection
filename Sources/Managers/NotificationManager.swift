import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func scheduleWorkStartNotification(for contact: Contact) {
        let content = UNMutableNotificationContent()
        content.title = "\(contact.name) has started work"
        content.body = "It's a good time to reach out to \(contact.name)"
        content.sound = .default

        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = contact.workStartTime.hour
        dateComponents.minute = contact.workStartTime.minute
        dateComponents.timeZone = timeZone

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: contact.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelNotification(for contactId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contactId.uuidString])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}