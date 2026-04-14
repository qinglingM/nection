import SwiftUI
import UserNotifications

struct RemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ContactStore.shared
    @State private var showingClearAllAlert = false
    @State private var pendingNotifications: [UNNotificationRequest] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()
                
                if pendingNotifications.isEmpty {
                    emptyStateView
                } else {
                    remindersListView
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
                
                if !pendingNotifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Mute Today") {
                            showingClearAllAlert = true
                        }
                        .foregroundColor(Color(hex: "FF9500"))
                    }
                }
            }
            .onAppear {
                loadPendingNotifications()
            }
            .alert("Mute Today's Reminders", isPresented: $showingClearAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Mute Today", role: .destructive) {
                    muteTodaysReminders()
                }
            } message: {
                Text("This will cancel all reminders scheduled for today. Tomorrow's reminders will remain active.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "8E8E93"))
            
            Text("Currently no reminders")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Reminders will appear here when contacts have 'Notify when work starts' enabled.")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "8E8E93"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "64D2FF"))
                    .frame(width: 200, height: 44)
                    .background(Color(hex: "3A3A3C"))
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var remindersListView: some View {
        List {
            ForEach(pendingNotifications, id: \.identifier) { notification in
                ReminderRow(
                    notification: notification,
                    onDelete: {
                        cancelReminder(notification.identifier)
                    }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "1C1C1E"))
    }
    
    private func loadPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                // 只显示工作开始提醒
                self.pendingNotifications = requests.filter { request in
                    request.content.title.contains("has started work")
                }
                print("Loaded \(self.pendingNotifications.count) reminders")
            }
        }
    }
    
    private func cancelReminder(_ identifier: String) {
        // 从通知标识符中提取联系人ID
        let contactId = identifier.replacingOccurrences(of: "work_start_", with: "")
        
        // 取消通知
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 强绑定：通知里关掉 = 卡片详情的开关被关掉
        if let uuid = UUID(uuidString: contactId),
           let contact = store.contacts.first(where: { $0.id == uuid }) {
            var updatedContact = contact
            updatedContact.notifyWhenWorkStarts = false
            store.updateContact(updatedContact)
            print("🔕 RemindersView: Notification cancelled and switch turned off for \(updatedContact.name)")
        }
        
        // 更新列表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            loadPendingNotifications()
        }
    }
    
    private func muteTodaysReminders() {
        let calendar = Calendar.current
        let today = Date()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            var requestsToCancel: [String] = []
            
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    // 检查是否是今天的提醒
                    if let triggerDate = calendar.date(from: trigger.dateComponents),
                       calendar.isDate(triggerDate, inSameDayAs: today) {
                        requestsToCancel.append(request.identifier)
                    }
                }
            }
            
            // 取消今天的提醒
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestsToCancel)
            
            print("Muted \(requestsToCancel.count) reminders for today")
            
            // 更新列表
            DispatchQueue.main.async {
                self.loadPendingNotifications()
            }
        }
    }
}

struct ReminderRow: View {
    let notification: UNNotificationRequest
    let onDelete: () -> Void
    
    // 从通知标题中提取联系人名字
    private var contactName: String {
        let title = notification.content.title
        if let range = title.range(of: " has started work") {
            return String(title[..<range.lowerBound])
        }
        return "Contact"
    }
    
    // 从触发器获取时间
    private var triggerTime: String {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
            return "Daily"
        }
        
        let hour = trigger.dateComponents.hour ?? 9
        let minute = trigger.dateComponents.minute ?? 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        
        return String(format: "%02d:%02d", hour, minute)
    }
    
    // 计算倒计时
    private var countdownText: String {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger,
              let triggerDate = Calendar.current.date(from: trigger.dateComponents) else {
            return ""
        }
        
        let now = Date()
        let timeInterval = triggerDate.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "At Your Time"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%02dm", minutes)
        }
    }
    
    // 获取时区
    private var timeZoneInfo: String {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger,
              let timeZone = trigger.dateComponents.timeZone else {
            return ""
        }
        
        let offset = timeZone.secondsFromGMT()
        let hours = offset / 3600
        
        if hours == 0 {
            return "UTC"
        } else if hours > 0 {
            return String(format: "UTC+%d", hours)
        } else {
            return String(format: "UTC%d", hours)
        }
    }
    
    // 获取闹铃时间（转换为用户本地时间）
    private func getAlarmTimeInUserTimeZone() -> String? {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger,
              let triggerDate = Calendar.current.date(from: trigger.dateComponents) else {
            return nil
        }
        
        // 将触发时间转换为用户本地时间
        let userTimeZone = TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = userTimeZone
        
        if UserSettings.shared.is24HourFormat {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: triggerDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 铃铛图标
            Image(systemName: "bell.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "64D2FF"))
                .frame(width: 40, height: 40)
                .background(Color(hex: "2C2C2E"))
                .cornerRadius(20)
            
            // 提醒信息
            VStack(alignment: .leading, spacing: 4) {
                Text(contactName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("Work start: \(triggerTime)")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8E8E93"))
                    
                    if !timeZoneInfo.isEmpty {
                        Text(timeZoneInfo)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "636366"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "2C2C2E"))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                // 倒计时显示
                if !countdownText.isEmpty {
                    Text(countdownText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "64D2FF"))
                }
                
                // 闹铃时间（用户本地时间）
                if let alarmTime = getAlarmTimeInUserTimeZone() {
                    HStack(spacing: 4) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "FF9500"))
                        
                        Text(alarmTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "2C2C2E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(hex: "FF9500").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            
            // 关闭按钮（带确认）
            Button(action: {
                // 显示确认对话框
                let alert = UIAlertController(
                    title: "Cancel Reminder",
                    message: "Are you sure you want to cancel this reminder?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
                    onDelete()
                })
                
                // 显示对话框
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "FF3B30"))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(hex: "3A3A3C"))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}