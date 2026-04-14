import SwiftUI
import UserNotifications

struct ContactListView: View {
    @StateObject private var store = ContactStore.shared
    @State private var showingAddContact = false
    @State private var showingReminders = false
    @State private var contactToDelete: Contact?
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    
    var body: some View {
        Group {
            if store.sortedContacts().isEmpty {
                emptyStateView
            } else {
                contactsListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "1C1C1E"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Left: Edit button and 24-hour format toggle
            ToolbarItemGroup(placement: .navigationBarLeading) {
                // Edit button (pencil icon)
                Button {
                    isEditing.toggle()
                } label: {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .foregroundColor(Color(hex: "64D2FF"))
                }
                
                // 24-hour format toggle button
                Button {
                    UserSettings.shared.is24HourFormat.toggle()
                } label: {
                    Image(systemName: UserSettings.shared.is24HourFormat ? "24.circle.fill" : "12.circle.fill")
                        .foregroundColor(Color(hex: "64D2FF"))
                        .font(.system(size: 18))
                }
            }
            
            // Center: Current time (aligned with add button)
            ToolbarItem(placement: .principal) {
                CurrentTimeInNavBar()
            }
            
            // Right: Add button and reminders button
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Reminders management button
                Button {
                    showingReminders = true
                } label: {
                    Image(systemName: "bell")
                        .foregroundColor(Color(hex: "FF9500"))
                }
                
                // Add contact button
                Button {
                    showingAddContact = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView()
        }
        .sheet(isPresented: $showingReminders) {
            RemindersView()
        }
        .alert("Delete Contact", isPresented: $showingDeleteAlert, presenting: contactToDelete) { contact in
            Button("Cancel", role: .cancel) {
                contactToDelete = nil
            }
            Button("Delete", role: .destructive) {
                confirmDelete()
            }
        } message: { contact in
            Text("Are you sure you want to delete \(contact.name)? This action cannot be undone.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("No Contacts")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Tap + to add your first contact")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "8E8E93"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddContact = true
            } label: {
                Text("Add Contact")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "64D2FF"))
                    .frame(width: 200, height: 44)
                    .background(Color(hex: "3A3A3C"))
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "1C1C1E"))
    }
    
    private var contactsListView: some View {
        List {
            ForEach(store.sortedContacts()) { contact in
                ZStack {
                    NavigationLink(destination: DetailView(contact: contact)) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    ContactCardViewFinal(contact: contact)
                        .listRowInsets(EdgeInsets(
                            top: 8,
                            leading: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 8,
                            bottom: 8,
                            trailing: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 8
                        ))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .contentShape(Rectangle())
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // 提醒按钮
                        Button {
                            toggleReminder(for: contact)
                        } label: {
                            Image(systemName: "bell.fill")
                        }
                        .tint(Color(hex: "FF9500"))
                        
                        // 删除按钮
                        Button(role: .destructive) {
                            showDeleteConfirmation(for: contact)
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                    }
            }
            // Enable drag sorting only in edit mode
            .onMove(perform: isEditing ? moveContacts : nil)
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "1C1C1E"))
    }
    
    private func deleteContact(_ contact: Contact) {
        store.deleteContact(contact)
    }
    
    private func moveContacts(from source: IndexSet, to destination: Int) {
        store.moveContact(from: source, to: destination)
    }
    
    private func toggleReminder(for contact: Contact) {
        var updatedContact = contact
        updatedContact.notifyWhenWorkStarts.toggle()
        
        store.updateContact(updatedContact)
        
        if updatedContact.notifyWhenWorkStarts {
            // 开启提醒
            NotificationManager.shared.scheduleWorkStartNotification(for: updatedContact)
            print("✅ Reminder enabled for \(updatedContact.name)")
        } else {
            // 关闭提醒
            NotificationManager.shared.cancelNotification(for: updatedContact.id)
            print("🔕 Reminder disabled for \(updatedContact.name)")
        }
    }
    
    private func showDeleteConfirmation(for contact: Contact) {
        contactToDelete = contact
        showingDeleteAlert = true
    }
    
    private func confirmDelete() {
        guard let contact = contactToDelete else { return }
        store.deleteContact(contact)
        contactToDelete = nil
    }
    

}

struct ContactCardViewFinal: View {
    let contact: Contact
    @StateObject private var userSettings = UserSettings.shared
    @State private var displayInfo: ContactDisplayInfo?
    @State private var workProgress: Double = 0.0
    @State private var progressColor: Color = Color(hex: "8E8E93")
    
    var body: some View {
        VStack(spacing: 0) {
            // 卡片内容
            HStack(alignment: .top, spacing: 12) {
            // 左侧信息
            VStack(alignment: .leading, spacing: 4) {
                // 名字
                HStack {
                    Text(contact.name)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if contact.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "64D2FF"))
                            .padding(.leading, 4)
                    }
                }
                
                Spacer()
                
                // First line: City + State/Province (if any)
                if !contact.city.isEmpty || !contact.state.isEmpty {
                    let cityState = [contact.city, contact.state]
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                    
                    Text(cityState)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                
                // Second line: Country
                if !contact.country.isEmpty {
                    Text(contact.country)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                
                // Third line: Work hours (if enabled)
                if contact.workHoursEnabled {
                    Text("\(userSettings.formatTime(contact.workStartTime)) - \(userSettings.formatTime(contact.workEndTime))")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "636366"))
                        .padding(.top, 2)
                }
            }
            .frame(minHeight: 100) // 确保左侧有足够高度
            
            Spacer(minLength: 8)
            
            // Right side: Time, timezone and status
            if contact.workHoursEnabled, let info = displayInfo {
                VStack(alignment: .trailing, spacing: 4) {
                    // Time display (based on 24-hour format setting)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        // Show AM/PM only in 12-hour format
                        if !userSettings.is24HourFormat, !info.amPM.isEmpty {
                            Text(info.amPM)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        
                        // Use getTimeOnly to get time without AM/PM
                        Text(userSettings.getTimeOnly(info.localTime, timeZone: TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current))
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 72 : 64, weight: .light))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    
                    // UTC timezone info (below time)
                    Text(getUTCDisplay(contact.timeZoneIdentifier))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                    
                    // Status and suggestion - traffic light three-state
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor(for: info.status))
                            .frame(width: 10, height: 10)
                        
                        Text(info.suggestion)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(statusColor(for: info.status))
                    }
                }
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    // Time display (when work hours disabled)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        // Show AM/PM only in 12-hour format
                        if !userSettings.is24HourFormat,
                           let displayInfo = displayInfo,
                           !displayInfo.amPM.isEmpty {
                            Text(displayInfo.amPM)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        
                        if let displayInfo = displayInfo {
                            Text(userSettings.getTimeOnly(displayInfo.localTime, timeZone: TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current))
                                .font(.system(size: 64, weight: .light))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        } else {
                            Text("--:--")
                                .font(.system(size: 64, weight: .light))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                    }
                    
                    // UTC timezone info
                    if let timeZoneId = displayInfo?.contact.timeZoneIdentifier {
                        Text(getUTCDisplay(timeZoneId))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                }
            }
            }
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
            
            // Bottom progress bar (aligned with card bottom edge)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar (full gray, shown when work hours disabled)
                    Rectangle()
                        .fill(Color(hex: "8E8E93"))
                        .frame(height: 2)
                        .opacity(0.3)
                    
                    // Progress bar
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * workProgress, height: 2)
                }
            }
            .frame(height: 2) // Very thin progress bar
            .offset(y: 1) // Fine-tune to align with card bottom edge
        }
        .background(Color(hex: "3A3A3C"))
        .cornerRadius(12)
        .onAppear {
            updateDisplayInfo()
            updateProgressBar()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateDisplayInfo()
        }
        .onReceive(Timer.publish(every: 300, on: .main, in: .common).autoconnect()) { _ in
            updateProgressBar() // 每5分钟更新一次进度
        }
    }
    
    private func updateDisplayInfo() {
        displayInfo = TimeZoneManager.shared.getDisplayInfo(for: contact)
    }
    
    private func formatTime(_ components: DateComponents) -> String {
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0
        return String(format: "%02d:%02d", hour, minute)
    }
    
    private func statusColor(for status: WorkStatus) -> Color {
        switch status {
        case .working: return Color(hex: "30D158")
        case .beforeWork: return Color(hex: "FF9500")
        case .afterHours: return Color(hex: "FF9500")
        case .weekend: return Color(hex: "FF3B30")
        }
    }
    
    private func getUTCDisplay(_ timeZoneIdentifier: String) -> String {
        let timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
        let offset = timeZone.secondsFromGMT()
        let hours = offset / 3600
        
        if hours == 0 {
            return "UTC+0"
        } else if hours > 0 {
            return String(format: "UTC+%d", hours)
        } else {
            return String(format: "UTC%d", hours)
        }
    }
    
    // 计算当前阶段的进度百分比 (0.0 到 1.0)
    // 逻辑：根据三态阶段计算在当前阶段的时间进度
    private func calculateWorkProgress() -> Double {
        guard contact.workHoursEnabled else { return 0.0 }
        
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let calendar = Calendar.current
        let now = Date()
        
        // 转换为联系人时区的当前时间
        var components = calendar.dateComponents(in: timeZone, from: now)
        let currentHour = components.hour ?? 0
        let currentMinute = components.minute ?? 0
        let currentMinutes = currentHour * 60 + currentMinute
        
        // 工作开始和结束时间（分钟）
        let startHour = contact.workStartTime.hour ?? 9
        let startMinute = contact.workStartTime.minute ?? 0
        let startMinutes = startHour * 60 + startMinute
        
        let endHour = contact.workEndTime.hour ?? 18
        let endMinute = contact.workEndTime.minute ?? 0
        let endMinutes = endHour * 60 + endMinute
        
        // 三态时间分段
        let sleepStartMinutes = 21 * 60  // 21:00
        let sleepEndMinutes = 6 * 60     // 6:00
        let dayStartMinutes = 6 * 60     // 6:00
        let dayEndMinutes = 21 * 60      // 21:00
        
        // 调试信息
        print("🔧 Stage Progress Calculation for \(contact.name):")
        print("  - current time: \(currentHour):\(currentMinute) (\(currentMinutes) minutes)")
        print("  - work hours: \(startHour):\(startMinute)-\(endHour):\(endMinute)")
        
        // 判断当前处于哪个阶段，并计算该阶段的进度
        if currentMinutes >= sleepStartMinutes || currentMinutes < sleepEndMinutes {
            // 红色阶段：21:00-6:00 (夜间/UNAVAILABLE)
            // 夜间段分为两段：21:00-24:00 和 0:00-6:00
            var progress: Double = 0.0
            
            if currentMinutes >= sleepStartMinutes {
                // 21:00-24:00 段
                let nightStart = sleepStartMinutes
                let nightEnd = 24 * 60
                let nightDuration = nightEnd - nightStart
                let elapsed = currentMinutes - nightStart
                progress = Double(elapsed) / Double(nightDuration)
                print("  - RED phase (21:00-24:00): \(progress)")
            } else {
                // 0:00-6:00 段
                let nightStart = 0
                let nightEnd = sleepEndMinutes
                let nightDuration = nightEnd - nightStart
                let elapsed = currentMinutes - nightStart
                progress = Double(elapsed) / Double(nightDuration)
                print("  - RED phase (0:00-6:00): \(progress)")
            }
            
            return min(max(progress, 0.0), 1.0)
            
        } else if currentMinutes >= startMinutes && currentMinutes <= endMinutes {
            // 绿色阶段：工作时间 (AVAILABLE)
            let workDuration = endMinutes - startMinutes
            let elapsed = currentMinutes - startMinutes
            let progress = Double(elapsed) / Double(workDuration)
            print("  - GREEN phase (work hours): \(progress) (\(elapsed)/\(workDuration))")
            return min(max(progress, 0.0), 1.0)
            
        } else if currentMinutes >= dayStartMinutes && currentMinutes < startMinutes {
            // 橙色阶段：工作时间前 (6:00-工作开始时间)
            let beforeWorkDuration = startMinutes - dayStartMinutes
            let elapsed = currentMinutes - dayStartMinutes
            let progress = Double(elapsed) / Double(beforeWorkDuration)
            print("  - ORANGE phase (before work): \(progress) (\(elapsed)/\(beforeWorkDuration))")
            return min(max(progress, 0.0), 1.0)
            
        } else if currentMinutes > endMinutes && currentMinutes < sleepStartMinutes {
            // 橙色阶段：工作时间后 (工作结束时间-21:00)
            let afterWorkDuration = sleepStartMinutes - endMinutes
            let elapsed = currentMinutes - endMinutes
            let progress = Double(elapsed) / Double(afterWorkDuration)
            print("  - ORANGE phase (after work): \(progress) (\(elapsed)/\(afterWorkDuration))")
            return min(max(progress, 0.0), 1.0)
            
        } else {
            // 默认情况
            print("  - Default phase: 0.0")
            return 0.0
        }
    }
    
    // 根据进度获取颜色
    private func getProgressColor(for progress: Double) -> Color {
        guard contact.workHoursEnabled else {
            return Color.clear // 工作时间关闭时，进度条透明（只显示背景条）
        }
        
        // 根据三态逻辑获取颜色
        if let info = displayInfo {
            return statusColor(for: info.status)
        }
        
        // 默认颜色
        return Color(hex: "8E8E93")
    }
    
    // 更新进度条
    private func updateProgressBar() {
        workProgress = calculateWorkProgress()
        progressColor = getProgressColor(for: workProgress)
        
        // 调试信息
        print("📊 ProgressBar Update for \(contact.name):")
        print("  - workHoursEnabled: \(contact.workHoursEnabled)")
        print("  - workProgress: \(workProgress)")
        print("  - progressColor: \(progressColor)")
        print("  - displayInfo: \(displayInfo != nil ? "available" : "nil")")
        if let info = displayInfo {
            print("  - status: \(info.status)")
            print("  - localTime: \(info.localTime)")
        }
        
        // 检查时间计算
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents(in: timeZone, from: now)
        let currentHour = components.hour ?? 0
        let currentMinute = components.minute ?? 0
        print("  - current time in contact timezone: \(currentHour):\(currentMinute)")
        
        // 检查工作时间
        let startHour = contact.workStartTime.hour ?? 9
        let startMinute = contact.workStartTime.minute ?? 0
        let endHour = contact.workEndTime.hour ?? 18
        let endMinute = contact.workEndTime.minute ?? 0
        print("  - work hours: \(startHour):\(startMinute) - \(endHour):\(endMinute)")
    }
}

struct CurrentTimeInNavBar: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 第一行：时间 + AM/PM（12小时制时才显示）
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                if !UserSettings.shared.is24HourFormat {
                    Text(formatTimeWithPeriod(currentTime))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                
                Text(UserSettings.shared.getTimeOnly(currentTime, timeZone: TimeZone.current))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // 第二行：UTC+8（换行显示）
            Text(getUTCDisplayForCurrent())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "8E8E93"))
                .padding(.top, 2)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }
    
    private func formatTimeWithPeriod(_ date: Date) -> String {
        guard !UserSettings.shared.is24HourFormat else { return "" }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "a"
        return formatter.string(from: date).uppercased()
    }
    
    private func getUTCDisplayForCurrent() -> String {
        let timeZone = TimeZone.current
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
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}