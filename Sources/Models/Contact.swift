import Foundation

struct Contact: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var country: String
    var state: String
    var city: String
    var timeZoneIdentifier: String
    var workStartTime: DateComponents
    var workEndTime: DateComponents
    var notifyWhenWorkStarts: Bool
    var isPinned: Bool
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String = "",
        country: String = "",
        state: String = "",
        city: String = "",
        timeZoneIdentifier: String = TimeZone.current.identifier,
        workStartTime: DateComponents = DateComponents(hour: 9, minute: 0),
        workEndTime: DateComponents = DateComponents(hour: 18, minute: 0),
        notifyWhenWorkStarts: Bool = false,
        isPinned: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.state = state
        self.city = city
        self.timeZoneIdentifier = timeZoneIdentifier
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.notifyWhenWorkStarts = notifyWhenWorkStarts
        self.isPinned = isPinned
        self.sortOrder = sortOrder
    }
}

enum WorkStatus: String, Codable {
    case working = "Working"
    case beforeWork = "Before work"
    case afterHours = "After hours"
    case weekend = "Weekend"

    var color: String {
        switch self {
        case .working: return "statusWorking"
        case .beforeWork: return "statusBeforeWork"
        case .afterHours: return "statusAfterHours"
        case .weekend: return "statusWeekend"
        }
    }
}

struct ContactDisplayInfo {
    let contact: Contact
    let localTime: Date
    let localTimeString: String
    let amPM: String
    let status: WorkStatus
    let suggestion: String
    let timeUntilWorkStart: TimeInterval?
    let timeUntilWorkEnd: TimeInterval?

    var locationDisplay: String {
        "\(contact.city) · \(contact.country)"
    }

    var workHoursDisplay: String {
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a"

        let startDate = Calendar.current.date(from: contact.workStartTime) ?? Date()
        let endDate = Calendar.current.date(from: contact.workEndTime) ?? Date()

        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var timeUntilWorkStartDisplay: String? {
        guard let interval = timeUntilWorkStart, interval > 0 else { return nil }
        return formatTimeInterval(interval) + " until work starts"
    }

    var timeUntilWorkEndDisplay: String? {
        guard let interval = timeUntilWorkEnd, interval > 0 else { return nil }
        return formatTimeInterval(interval) + " until end of work"
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}