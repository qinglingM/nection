import Foundation

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var is24HourFormat: Bool {
        didSet {
            UserDefaults.standard.set(is24HourFormat, forKey: "is24HourFormat")
        }
    }
    
    private init() {
        self.is24HourFormat = UserDefaults.standard.object(forKey: "is24HourFormat") as? Bool ?? true // 默认24小时制
    }
    
    // 格式化时间，根据设置返回12或24小时制
    func formatTime(_ date: Date, timeZone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone ?? TimeZone.current
        
        if is24HourFormat {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: date)
    }
    
    // 格式化时间组件
    func formatTime(_ components: DateComponents) -> String {
        guard let hour = components.hour, let minute = components.minute else {
            return "00:00"
        }
        
        if is24HourFormat {
            return String(format: "%02d:%02d", hour, minute)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let calendar = Calendar.current
            if let date = calendar.date(from: dateComponents) {
                return formatter.string(from: date)
            }
            return String(format: "%02d:%02d", hour, minute)
        }
    }
    
    // 获取AM/PM部分（仅12小时制）
    func getAMPM(_ date: Date, timeZone: TimeZone? = nil) -> String {
        guard !is24HourFormat else { return "" }
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone ?? TimeZone.current
        formatter.dateFormat = "a"
        
        return formatter.string(from: date)
    }
    
    // 获取时间部分（不含AM/PM）
    func getTimeOnly(_ date: Date, timeZone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone ?? TimeZone.current
        
        if is24HourFormat {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm"
        }
        
        return formatter.string(from: date)
    }
}