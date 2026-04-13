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
    var workHoursEnabled: Bool

    // 自定义编码键
    enum CodingKeys: String, CodingKey {
        case id, name, country, state, city, timeZoneIdentifier
        case workStartHour, workStartMinute
        case workEndHour, workEndMinute
        case notifyWhenWorkStarts, isPinned, sortOrder, workHoursEnabled
    }

    // 自定义编码
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(country, forKey: .country)
        try container.encode(state, forKey: .state)
        try container.encode(city, forKey: .city)
        try container.encode(timeZoneIdentifier, forKey: .timeZoneIdentifier)
        try container.encode(workStartTime.hour ?? 9, forKey: .workStartHour)
        try container.encode(workStartTime.minute ?? 0, forKey: .workStartMinute)
        try container.encode(workEndTime.hour ?? 18, forKey: .workEndHour)
        try container.encode(workEndTime.minute ?? 0, forKey: .workEndMinute)
        try container.encode(notifyWhenWorkStarts, forKey: .notifyWhenWorkStarts)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(workHoursEnabled, forKey: .workHoursEnabled)
    }

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
        sortOrder: Int = 0,
        workHoursEnabled: Bool = true
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
        self.workHoursEnabled = workHoursEnabled
    }
    
    // 自定义解码
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        state = try container.decode(String.self, forKey: .state)
        city = try container.decode(String.self, forKey: .city)
        timeZoneIdentifier = try container.decode(String.self, forKey: .timeZoneIdentifier)
        
        let startHour = try container.decode(Int.self, forKey: .workStartHour)
        let startMinute = try container.decode(Int.self, forKey: .workStartMinute)
        workStartTime = DateComponents(hour: startHour, minute: startMinute)
        
        let endHour = try container.decode(Int.self, forKey: .workEndHour)
        let endMinute = try container.decode(Int.self, forKey: .workEndMinute)
        workEndTime = DateComponents(hour: endHour, minute: endMinute)
        
        notifyWhenWorkStarts = try container.decode(Bool.self, forKey: .notifyWhenWorkStarts)
        isPinned = try container.decode(Bool.self, forKey: .isPinned)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        workHoursEnabled = try container.decode(Bool.self, forKey: .workHoursEnabled)
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
        
        let startDate = Calendar.current.date(from: contact.workStartTime) ?? Date()
        let endDate = Calendar.current.date(from: contact.workEndTime) ?? Date()

        let startTime = UserSettings.shared.formatTime(startDate, timeZone: timeZone)
        let endTime = UserSettings.shared.formatTime(endDate, timeZone: timeZone)

        return "\(startTime) - \(endTime)"
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