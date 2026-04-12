import Foundation
import Combine

final class TimeZoneManager: ObservableObject {
    static let shared = TimeZoneManager()

    private init() {}

    func getDisplayInfo(for contact: Contact) -> ContactDisplayInfo {
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let calendar = Calendar.current
        let now = Date()

        let localTime = now
        let localTimeString = formatTime(localTime, in: timeZone)
        let amPM = formatTimeWithPeriod(localTime, in: timeZone)

        let weekday = calendar.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7

        let workStartMinutes = (contact.workStartTime.hour ?? 9) * 60 + (contact.workStartTime.minute ?? 0)
        let workEndMinutes = (contact.workEndTime.hour ?? 18) * 60 + (contact.workEndTime.minute ?? 0)

        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)

        var status: WorkStatus
        var suggestion: String
        var timeUntilWorkStart: TimeInterval? = nil
        var timeUntilWorkEnd: TimeInterval? = nil

        if isWeekend {
            status = .weekend
            suggestion = "They're likely offline"
        } else if currentMinutes < workStartMinutes {
            status = .beforeWork
            suggestion = "Wait until morning"

            let todayWorkStart = calendar.date(bySettingHour: contact.workStartTime.hour ?? 9,
                                                minute: contact.workStartTime.minute ?? 0,
                                                second: 0,
                                                of: now) ?? now
            timeUntilWorkStart = todayWorkStart.timeIntervalSince(now)
        } else if currentMinutes >= workEndMinutes {
            status = .afterHours
            suggestion = "Better to message later"
        } else {
            status = .working
            suggestion = "Good time to message"

            let todayWorkEnd = calendar.date(bySettingHour: contact.workEndTime.hour ?? 18,
                                              minute: contact.workEndTime.minute ?? 0,
                                              second: 0,
                                              of: now) ?? now
            timeUntilWorkEnd = todayWorkEnd.timeIntervalSince(now)
        }

        return ContactDisplayInfo(
            contact: contact,
            localTime: localTime,
            localTimeString: localTimeString,
            amPM: amPM,
            status: status,
            suggestion: suggestion,
            timeUntilWorkStart: timeUntilWorkStart,
            timeUntilWorkEnd: timeUntilWorkEnd
        )
    }

    private func formatTime(_ date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }
    
    private func formatTimeWithPeriod(_ date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "a"
        return formatter.string(from: date).uppercased()
    }
}

final class ContactStore: ObservableObject {
    static let shared = ContactStore()

    @Published var contacts: [Contact] = []

    private let userDefaultsKey = "stored_contacts"

    private init() {
        loadContacts()
    }

    func addContact(_ contact: Contact) {
        var newContact = contact
        newContact.sortOrder = contacts.count
        contacts.append(newContact)
        saveContacts()
    }

    func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
        }
    }

    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }

    func moveContact(from source: IndexSet, to destination: Int) {
        contacts.move(fromOffsets: source, toOffset: destination)
        updateSortOrders()
        saveContacts()
    }

    func togglePin(for contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index].isPinned.toggle()
            saveContacts()
        }
    }

    func sortedContacts() -> [Contact] {
        let pinned = contacts.filter { $0.isPinned }.sorted { $0.sortOrder < $1.sortOrder }
        let unpinned = contacts.filter { !$0.isPinned }.sorted { $0.sortOrder < $1.sortOrder }
        return pinned + unpinned
    }

    private func updateSortOrders() {
        for (index, _) in contacts.enumerated() {
            contacts[index].sortOrder = index
        }
    }

    private func saveContacts() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadContacts() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Contact].self, from: data) {
            contacts = decoded
        }
    }
}