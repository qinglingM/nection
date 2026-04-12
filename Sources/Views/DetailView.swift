import SwiftUI

struct DetailView: View {
    let contact: Contact
    @StateObject private var store = ContactStore.shared
    @State private var displayInfo: ContactDisplayInfo?
    @State private var showingEditContact = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                bigTimeSection

                statusSection

                workHoursSection

                suggestionSection

                if let info = displayInfo {
                    timeUntilSection(info: info)
                }

                notificationToggle

                editButton
            }
            .padding(.vertical, 24)
        }
        .background(Color(hex: "1C1C1E"))
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditContact = true
                }
                .foregroundColor(Color(hex: "64D2FF"))
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
        VStack(spacing: 2) {
            Text(displayInfo?.localTimeString ?? "--:--")
                .font(.system(size: 96, weight: .thin))
                .foregroundColor(.white)
            
            if let amPM = displayInfo?.amPM, !amPM.isEmpty {
                Text(amPM)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
        }
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

    private var editButton: some View {
        Button {
            showingEditContact = true
        } label: {
            Text("Edit Contact")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "64D2FF"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(hex: "3A3A3C"))
                .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }

    private func statusColor(for status: WorkStatus) -> Color {
        switch status {
        case .working: return Color(hex: "30D158")
        case .beforeWork: return Color(hex: "64D2FF")
        case .afterHours: return Color(hex: "98989D")
        case .weekend: return Color(hex: "636366")
        }
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
        case .working: return "Working now"
        case .beforeWork: return "Before work"
        case .afterHours: return "After hours"
        case .weekend: return "Weekend"
        }
    }

    var foregroundColor: Color {
        switch status {
        case .working: return Color(hex: "30D158")
        case .beforeWork: return Color(hex: "64D2FF")
        case .afterHours: return Color(hex: "98989D")
        case .weekend: return Color(hex: "636366")
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