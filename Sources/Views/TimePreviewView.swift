import SwiftUI

struct TimePreviewView: View {
    let contact: Contact
    @StateObject private var store = ContactStore.shared
    @State private var displayInfo: ContactDisplayInfo?
    @State private var showingTimeEditor = false
    @State private var editedWorkStartTime: Date
    @State private var editedWorkEndTime: Date
    
    init(contact: Contact) {
        self.contact = contact
        
        // 初始化编辑时间
        let calendar = Calendar.current
        let startDate = calendar.date(from: contact.workStartTime) ?? calendar.date(from: DateComponents(hour: 9, minute: 0))!
        let endDate = calendar.date(from: contact.workEndTime) ?? calendar.date(from: DateComponents(hour: 18, minute: 0))!
        
        _editedWorkStartTime = State(initialValue: startDate)
        _editedWorkEndTime = State(initialValue: endDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Text("工作时间")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingTimeEditor = true
                }) {
                    Text("编辑")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "64D2FF"))
                }
            }
            
            // 时间预览卡片
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("上班时间")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                        
                        Text(formatTime(contact.workStartTime))
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("下班时间")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                        
                        Text(formatTime(contact.workEndTime))
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                // 状态指示器
                if let displayInfo = displayInfo {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor(for: displayInfo.status))
                            .frame(width: 8, height: 8)
                        
                        Text(displayInfo.suggestion)
                            .font(.system(size: 14))
                            .foregroundColor(statusColor(for: displayInfo.status))
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "2C2C2E"))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "1C1C1E"))
        .onAppear {
            updateDisplayInfo()
        }
        .sheet(isPresented: $showingTimeEditor) {
            TimeEditorView(
                workStartTime: $editedWorkStartTime,
                workEndTime: $editedWorkEndTime,
                onSave: saveTimes
            )
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
        case .working:
            return Color(hex: "30D158")
        case .beforeWork:
            return Color(hex: "64D2FF")
        case .afterHours:
            return Color(hex: "98989D")
        case .weekend:
            return Color(hex: "636366")
        }
    }
    
    private func saveTimes() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: editedWorkStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: editedWorkEndTime)
        
        // 更新联系人
        var updatedContact = contact
        updatedContact.workStartTime = startComponents
        updatedContact.workEndTime = endComponents
        
        store.updateContact(updatedContact)
        updateDisplayInfo()
    }
}

struct TimeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var workStartTime: Date
    @Binding var workEndTime: Date
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("上班时间", selection: $workStartTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                    
                    DatePicker("下班时间", selection: $workEndTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                } header: {
                    Text("设置工作时间")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "2C2C2E"))
                
                Section {
                    Text("设置联系人所在时区的标准工作时间")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8E8E93"))
                } header: {
                    Text("说明")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "1C1C1E"))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .navigationTitle("编辑工作时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                    .fontWeight(.semibold)
                }
            }
        }
    }
}