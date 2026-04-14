import Foundation

final class TimeZoneManager {
    static let shared = TimeZoneManager()
    
    private init() {}
    
    func getDisplayInfo(for contact: Contact) -> ContactDisplayInfo {
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let calendar = Calendar.current
        let now = Date()
        
        // Convert current time to contact's timezone
        var contactCalendar = calendar
        contactCalendar.timeZone = timeZone
        let contactTime = now
        
        // 使用 UserSettings 格式化时间
        let localTimeString: String
        let amPM: String
        
        if UserSettings.shared.is24HourFormat {
            // 24小时制：只返回时间，不返回AM/PM
            localTimeString = UserSettings.shared.formatTime(contactTime, timeZone: timeZone)
            amPM = ""
        } else {
            // 12小时制：返回时间和AM/PM
            localTimeString = UserSettings.shared.getTimeOnly(contactTime, timeZone: timeZone)
            amPM = UserSettings.shared.getAMPM(contactTime, timeZone: timeZone)
        }
        
        // 确定状态
        let status = determineWorkStatus(for: contact, at: contactTime, in: timeZone)
        let suggestion = getSuggestion(for: status)
        
        // 位置显示
        let locationDisplay = getLocationDisplay(for: contact)
        
        return ContactDisplayInfo(
            contact: contact,
            localTime: contactTime,
            localTimeString: localTimeString,
            amPM: amPM,
            status: status,
            suggestion: suggestion,
            timeUntilWorkStart: nil,
            timeUntilWorkEnd: nil
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
    
    private func determineWorkStatus(for contact: Contact, at date: Date, in timeZone: TimeZone) -> WorkStatus {
        guard contact.workHoursEnabled else {
            return .weekend
        }
        
        let calendar = Calendar.current
        var contactCalendar = calendar
        contactCalendar.timeZone = timeZone
        
        let components = contactCalendar.dateComponents([.hour, .minute, .weekday], from: date)
        guard let hour = components.hour,
              let minute = components.minute,
              let weekday = components.weekday else {
            return .weekend
        }
        
        // 检查是否是周末
        if weekday == 1 || weekday == 7 { // 1 = Sunday, 7 = Saturday
            return .weekend
        }
        
        let totalMinutes = hour * 60 + minute
        
        guard let workStartHour = contact.workStartTime.hour,
              let workStartMinute = contact.workStartTime.minute,
              let workEndHour = contact.workEndTime.hour,
              let workEndMinute = contact.workEndTime.minute else {
            return .weekend
        }
        
        let workStartMinutes = workStartHour * 60 + workStartMinute
        let workEndMinutes = workEndHour * 60 + workEndMinute
        
        // 三态逻辑
        if totalMinutes >= 21 * 60 || totalMinutes < 6 * 60 {
            // 21:00 - 6:00: UNAVAILABLE
            return .weekend
        } else if totalMinutes >= workStartMinutes && totalMinutes <= workEndMinutes {
            // 工作时间: AVAILABLE
            return .working
        } else if totalMinutes < workStartMinutes {
            // 工作时间前: OFF DUTY (before work)
            return .beforeWork
        } else {
            // 工作时间后: OFF DUTY (after hours)
            return .afterHours
        }
    }
    
    private func getSuggestion(for status: WorkStatus) -> String {
        switch status {
        case .working:
            return "AVAILABLE"
        case .beforeWork:
            return "OFF DUTY"
        case .afterHours:
            return "OFF DUTY"
        case .weekend:
            return "UNAVAILABLE"
        }
    }
    
    private func getLocationDisplay(for contact: Contact) -> String {
        var parts: [String] = []
        
        if !contact.country.isEmpty {
            parts.append(contact.country)
        }
        
        if !contact.city.isEmpty {
            parts.append(contact.city)
        }
        
        return parts.joined(separator: " · ")
    }
}

