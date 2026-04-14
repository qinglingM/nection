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
            .onChange(of: store.contacts) { _ in
                // 当联系人数据变化时，重新加载通知
                print("📊 Contact store changed, reloading notifications in 0.5s...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    loadPendingNotifications()
                }
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
            // 先显示置顶联系人的提醒，然后显示非置顶的
            ForEach(sortedNotifications(), id: \.identifier) { notification in
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
    
    // 排序通知：置顶联系人优先
    private func sortedNotifications() -> [UNNotificationRequest] {
        return pendingNotifications.sorted { notification1, notification2 in
            // 从通知标识符中提取联系人ID
            let id1 = notification1.identifier.replacingOccurrences(of: "work_start_", with: "")
            let id2 = notification2.identifier.replacingOccurrences(of: "work_start_", with: "")
            
            guard let uuid1 = UUID(uuidString: id1),
                  let uuid2 = UUID(uuidString: id2) else {
                return false
            }
            
            // 查找联系人
            let contact1 = store.contacts.first { $0.id == uuid1 }
            let contact2 = store.contacts.first { $0.id == uuid2 }
            
            // 置顶的优先
            if let pinned1 = contact1?.isPinned, let pinned2 = contact2?.isPinned {
                if pinned1 != pinned2 {
                    return pinned1 // 置顶的排前面
                }
            }
            
            // 然后按名字排序
            let name1 = contact1?.name ?? ""
            let name2 = contact2?.name ?? ""
            return name1 < name2
        }
    }
    
    private func loadPendingNotifications() {
        print("🔄 Loading pending notifications...")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 System has \(requests.count) total notifications")
            
            let workStartNotifications = requests.filter { request in
                request.content.title.contains("has started work")
            }
            
            print("🔔 Found \(workStartNotifications.count) work start reminders")
            for notification in workStartNotifications {
                print("  - \(notification.identifier): \(notification.content.title)")
            }
            
            DispatchQueue.main.async {
                self.pendingNotifications = workStartNotifications
                print("✅ Loaded \(self.pendingNotifications.count) reminders into UI")
            }
        }
    }
    
    private func cancelReminder(_ identifier: String) {
        print("🔄 cancelReminder called with identifier: \(identifier)")
        
        // 从通知标识符中提取联系人ID
        let contactId = identifier.replacingOccurrences(of: "work_start_", with: "")
        print("  - Extracted contactId: \(contactId)")
        
        // 取消通知
        print("  - Removing notification from system...")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 核心同步：通知里关掉 = 卡片详情的开关被关掉
        if let uuid = UUID(uuidString: contactId) {
            print("  - Parsed UUID: \(uuid)")
            
            if let contact = store.contacts.first(where: { $0.id == uuid }) {
                print("  - Found contact: \(contact.name)")
                
                var updatedContact = contact
                updatedContact.notifyWhenWorkStarts = false
                store.updateContact(updatedContact)
                print("✅ RemindersView: Notification cancelled and switch turned off for \(updatedContact.name)")
            } else {
                print("⚠️ Contact not found in store for UUID: \(uuid)")
                print("  - Available contacts: \(store.contacts.map { "\($0.name): \($0.id)" })")
            }
        } else {
            print("❌ Failed to parse UUID from: \(contactId)")
        }
        
        // 更新列表
        print("  - Reloading notifications in 0.5s...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
    
    // 计算倒计时（每日提醒，永远不会超过24小时）
    private var countdownText: String {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
            return ""
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // 关键：每日重复提醒，总是计算下一个提醒时间
        // 获取触发时间的小时和分钟
        let triggerHour = trigger.dateComponents.hour ?? 9
        let triggerMinute = trigger.dateComponents.minute ?? 0
        let triggerTimeZone = trigger.dateComponents.timeZone ?? TimeZone.current
        
        // 在触发器时区中计算
        var components = calendar.dateComponents(in: triggerTimeZone, from: now)
        components.hour = triggerHour
        components.minute = triggerMinute
        components.second = 0
        
        guard let todayAlarm = calendar.date(from: components) else {
            return ""
        }
        
        // 计算下一个提醒时间
        let nextAlarm: Date
        if now < todayAlarm {
            // 今天的提醒还没到
            nextAlarm = todayAlarm
        } else {
            // 今天的提醒已过，计算明天的
            guard let tomorrowAlarm = calendar.date(byAdding: .day, value: 1, to: todayAlarm) else {
                return ""
            }
            nextAlarm = tomorrowAlarm
        }
        
        let timeInterval = nextAlarm.timeIntervalSince(now)
        
        // 验证：每日提醒永远不会超过24小时
        let totalHours = timeInterval / 3600
        if totalHours >= 24 {
            print("❌ LOGIC ERROR: Daily reminder shows \(String(format: "%.1f", totalHours))h!")
            print("  - Trigger: \(triggerHour):\(triggerMinute) in \(triggerTimeZone.identifier)")
            print("  - Now: \(now) in current timezone")
            print("  - Today alarm: \(todayAlarm)")
            print("  - Next alarm: \(nextAlarm)")
            print("  - This should never happen for daily reminders!")
            return "Error" // 显示错误，让我们知道有问题
        }
        
        if timeInterval <= 60 { // 1分钟内
            return "Now"
        }
        
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
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
    
    // 获取闹铃时间（用户本地时间，显示下一个提醒时间）
    private func getAlarmTimeInUserTimeZone() -> String? {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
            return nil
        }
        
        let now = Date()
        let calendar = Calendar.current
        let userTimeZone = TimeZone.current
        
        // 获取今天这个时间
        var todayComponents = calendar.dateComponents(in: userTimeZone, from: now)
        todayComponents.hour = trigger.dateComponents.hour ?? 9
        todayComponents.minute = trigger.dateComponents.minute ?? 0
        todayComponents.second = 0
        
        guard let todayAlarm = calendar.date(from: todayComponents) else {
            return nil
        }
        
        // 计算下一个提醒时间
        let nextAlarm: Date
        if now < todayAlarm {
            // 今天的提醒还没到
            nextAlarm = todayAlarm
        } else {
            // 今天的提醒已过，计算明天的
            guard let tomorrowAlarm = calendar.date(byAdding: .day, value: 1, to: todayAlarm) else {
                return nil
            }
            nextAlarm = tomorrowAlarm
        }
        
        // 格式化显示
        let formatter = DateFormatter()
        formatter.timeZone = userTimeZone
        
        if UserSettings.shared.is24HourFormat {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: nextAlarm)
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
            
            VStack(alignment: .trailing, spacing: 8) {
                // 倒计时显示 - 统一大小
                if !countdownText.isEmpty {
                    VStack(spacing: 2) {
                        Text("Countdown")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "64D2FF"))
                        
                        Text(countdownText)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "64D2FF"))
                    }
                    .frame(minWidth: 70) // 统一最小宽度
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "2C2C2E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "64D2FF").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // 闹铃时间（用户本地时间）- 统一大小
                if let alarmTime = getAlarmTimeInUserTimeZone() {
                    VStack(spacing: 2) {
                        Text("My Alarm")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "FF9500"))
                        
                        Text(alarmTime)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 70) // 统一最小宽度
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "2C2C2E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "FF9500").opacity(0.4), lineWidth: 1.5)
                            )
                    )
                }
            }
            
            // 关闭按钮（直接执行）
            Button(action: {
                print("🟡 X button tapped - Step 1: Button action triggered")
                print("  - Notification ID: \(notification.identifier)")
                print("  - Contact name from title: \(contactName)")
                onDelete()
                print("🟢 X button tapped - Step 2: onDelete callback executed")
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "FF3B30"))
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle()) // 确保整个区域可点击
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color(hex: "3A3A3C"))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}