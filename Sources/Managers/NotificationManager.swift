import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        print("Requesting notification authorization...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error)")
            } else {
                print("✅ Notification authorization granted: \(granted)")
                if granted {
                    self.checkNotificationSettings()
                }
            }
        }
    }
    
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("📱 Notification settings:")
            print("  - Authorization status: \(settings.authorizationStatus.rawValue)")
            print("  - Alert style: \(settings.alertStyle.rawValue)")
            print("  - Badge: \(settings.badgeSetting.rawValue)")
            print("  - Sound: \(settings.soundSetting.rawValue)")
        }
    }

    func scheduleWorkStartNotification(for contact: Contact) {
        print("📅 Scheduling notification for \(contact.name)...")
        
        // 检查通知权限
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("❌ Cannot schedule notification: authorization status is \(settings.authorizationStatus.rawValue)")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "\(contact.name) has started work"
            content.body = "It's a good time to reach out to \(contact.name)"
            content.sound = .default

            let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
            
            // 创建明天的工作开始时间
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.hour = contact.workStartTime.hour ?? 9
            dateComponents.minute = contact.workStartTime.minute ?? 0
            dateComponents.timeZone = timeZone
            
            // 设置为明天的这个时间
            let now = Date()
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
            let tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            dateComponents.year = tomorrowComponents.year
            dateComponents.month = tomorrowComponents.month
            dateComponents.day = tomorrowComponents.day
            
            print("  - Contact: \(contact.name)")
            print("  - Work start: \(contact.workStartTime.hour ?? 9):\(contact.workStartTime.minute ?? 0)")
            print("  - Time zone: \(timeZone.identifier)")
            print("  - Trigger date: \(dateComponents)")
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(
                identifier: "work_start_\(contact.id.uuidString)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule notification: \(error)")
                } else {
                    print("✅ Notification scheduled successfully for \(contact.name)")
                    
                    // 检查已调度的通知
                    self.listScheduledNotifications()
                }
            }
        }
    }
    
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Currently scheduled notifications: \(requests.count)")
            for request in requests {
                print("  - ID: \(request.identifier)")
                print("  - Title: \(request.content.title)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  - Trigger: \(trigger.dateComponents)")
                }
            }
        }
    }
    
    func getReminderCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let reminderCount = requests.filter { request in
                request.content.title.contains("has started work")
            }.count
            completion(reminderCount)
        }
    }

    func cancelNotification(for contactId: UUID) {
        let identifier = "work_start_\(contactId.uuidString)"
        print("🔕 Cancelling notification with identifier: \(identifier)")
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 验证是否真的删除了
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let remaining = requests.filter { $0.identifier == identifier }
            if remaining.isEmpty {
                print("✅ Notification cancelled successfully")
            } else {
                print("❌ Notification still exists after cancellation")
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}