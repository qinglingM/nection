import SwiftUI

struct DetailView: View {
    let contact: Contact
    @StateObject private var store = ContactStore.shared
    @StateObject private var userSettings = UserSettings.shared
    @State private var displayInfo: ContactDisplayInfo?
    @State private var showingEditContact = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                bigTimeSection

                statusSection

                // 时钟可视化组件
                VStack(spacing: 12) {
                    ClockView(contact: contact)
                        .frame(height: 140) // 控制时钟组件高度
                }
                .padding(.horizontal, 16)
                
                // Work Hours Toggle
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("WORK HOURS")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { contact.workHoursEnabled },
                            set: { newValue in
                                var updated = contact
                                updated.workHoursEnabled = newValue
                                store.updateContact(updated)
                            }
                        ))
                        .labelsHidden()
                        .tint(Color(hex: "30D158"))
                    }
                    
                    if contact.workHoursEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("START")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    
                                    Text(formatTime(contact.workStartTime))
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("END")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    
                                    Text(formatTime(contact.workEndTime))
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(hex: "2C2C2E"))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "1C1C1E"))

                suggestionSection

                notificationToggle
            }
            .padding(.vertical, 24)
        }
        .background(Color(hex: "1C1C1E"))
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditContact = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
        .sheet(isPresented: $showingEditContact) {
            EditContactView(contact: contact)
        }
        .onAppear {
            refreshDisplayInfo()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            refreshDisplayInfo()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(contact.name)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)

            Text("\(contact.country) · \(contact.city)")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "8E8E93"))
        }
    }

    private var bigTimeSection: some View {
        VStack(spacing: 8) {
            // 联系人本地时间
            VStack(spacing: 4) {
                if let displayInfo = displayInfo {
                    // 大时间
                    let timeString = userSettings.getTimeOnly(displayInfo.localTime, timeZone: TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current)
                    Text(timeString)
                        .font(.system(size: 96, weight: .thin))
                        .foregroundColor(.white)
                    
                    // AM/PM显示在时间正下方（12小时制时）
                    if !userSettings.is24HourFormat, !displayInfo.amPM.isEmpty {
                        Text(displayInfo.amPM)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                } else {
                    Text("--:--")
                        .font(.system(size: 96, weight: .thin))
                        .foregroundColor(.white)
                }
            }
            
            // 用户本地时间（被框起来的小标签）
            HStack(spacing: 6) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "64D2FF"))
                
                Text("YOUR TIME")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "64D2FF"))
                
                Text(formatUserLocalTime())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
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
    }
    
    private func formatUserLocalTime() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        if UserSettings.shared.is24HourFormat {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: now)
    }

    private var statusSection: some View {
        HStack(spacing: 12) {
            if let info = displayInfo {
                StatusBadgeLarge(status: info.status)
            }
        }
    }

    private var workHoursSection: some View {
        Text("Today: \(displayInfo?.workHoursDisplay ?? "--")")
            .font(.system(size: 15))
            .foregroundColor(Color(hex: "8E8E93"))
    }

    private var suggestionSection: some View {
        Group {
            if let info = displayInfo {
                Text(info.suggestion)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(statusColor(for: info.status))
            }
        }
    }

    private func timeUntilSection(info: ContactDisplayInfo) -> some View {
        Group {
            if let text = info.timeUntilWorkStartDisplay {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "636366"))
            } else if let text = info.timeUntilWorkEndDisplay {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "636366"))
            }
        }
    }

    private var notificationToggle: some View {
        let currentContact = store.contacts.first { $0.id == contact.id } ?? contact

        return HStack {
            Text("Notify when work starts")
                .font(.system(size: 16))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: Binding(
                get: { currentContact.notifyWhenWorkStarts },
                set: { newValue in
                    var updated = currentContact
                    updated.notifyWhenWorkStarts = newValue
                    store.updateContact(updated)
                    
                    // 强绑定：开关状态与通知完全同步
                    if newValue {
                        // 开启开关 → 必须调度通知
                        NotificationManager.shared.scheduleWorkStartNotification(for: updated)
                        print("✅ DetailView: Notification scheduled for \(updated.name)")
                    } else {
                        // 关闭开关 → 必须取消通知
                        NotificationManager.shared.cancelNotification(for: updated.id)
                        print("🔕 DetailView: Notification cancelled for \(updated.name)")
                    }
                }
            ))
            .labelsHidden()
            .tint(Color(hex: "30D158"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(hex: "3A3A3C"))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }



    private func statusColor(for status: WorkStatus) -> Color {
        switch status {
        case .working: return Color(hex: "30D158")  // 绿色 - AVAILABLE
        case .beforeWork: return Color(hex: "FF9500")  // 橙色 - OFF DUTY
        case .afterHours: return Color(hex: "FF9500")  // 橙色 - OFF DUTY
        case .weekend: return Color(hex: "FF3B30")  // 红色 - UNAVAILABLE
        }
    }
    
    private func formatTime(_ components: DateComponents) -> String {
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0
        return String(format: "%02d:%02d", hour, minute)
    }

    private func refreshDisplayInfo() {
        let currentContact = store.contacts.first { $0.id == contact.id } ?? contact
        displayInfo = TimeZoneManager.shared.getDisplayInfo(for: currentContact)
    }
}

struct StatusBadgeLarge: View {
    let status: WorkStatus

    var body: some View {
        Text(statusText)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color(hex: "1C1C1E"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(foregroundColor)
            .cornerRadius(8)
    }

    var statusText: String {
        switch status {
        case .working: return "AVAILABLE"
        case .beforeWork: return "OFF DUTY"
        case .afterHours: return "OFF DUTY"
        case .weekend: return "UNAVAILABLE"
        }
    }

    var foregroundColor: Color {
        switch status {
        case .working: return Color(hex: "30D158")  // 绿色 - AVAILABLE
        case .beforeWork: return Color(hex: "FF9500")  // 橙色 - OFF DUTY
        case .afterHours: return Color(hex: "FF9500")  // 橙色 - OFF DUTY
        case .weekend: return Color(hex: "FF3B30")  // 红色 - UNAVAILABLE
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(contact: Contact(
            name: "Daniel",
            country: "United Kingdom",
            city: "London",
            timeZoneIdentifier: "Europe/London",
            workStartTime: DateComponents(hour: 9, minute: 0),
            workEndTime: DateComponents(hour: 18, minute: 0)
        ))
    }
    .preferredColorScheme(.dark)
}