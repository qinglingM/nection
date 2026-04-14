import SwiftUI

struct ClockView: View {
    let contact: Contact
    @StateObject private var userSettings = UserSettings.shared
    @State private var currentTime = Date()
    @State private var rotation: Double = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            // 时钟标题
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "64D2FF"))

                Text("LOCAL TIME")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 时钟可视化组件
            ZStack {
                // 时钟外圈
                Circle()
                    .stroke(Color(hex: "2C2C2E"), lineWidth: 6)
                    .frame(width: 120, height: 120)

                // 时钟刻度
                ForEach(0..<12) { index in
                    Rectangle()
                        .fill(Color(hex: "8E8E93"))
                        .frame(width: 2, height: index % 3 == 0 ? 12 : 6)
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(index) * 30))
                }

                // 时针
                Rectangle()
                    .fill(Color(hex: "64D2FF"))
                    .frame(width: 4, height: 30)
                    .offset(y: -15)
                    .rotationEffect(.degrees(rotation * 360))

                // 分针
                Rectangle()
                    .fill(Color(hex: "30D158"))
                    .frame(width: 3, height: 42)
                    .offset(y: -20)
                    .rotationEffect(.degrees(rotation * 360 * 12))

                // 中心点
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)

                // 移除数字时间显示（避免重复）
            }
            .frame(height: 160)

            // 时区信息
            Text(getTimeZoneDisplay(contact.timeZoneIdentifier))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .padding(16)
        .background(Color(hex: "2C2C2E"))
        .cornerRadius(16)
        .onAppear {
            updateTime()
        }
        .onReceive(timer) { _ in
            updateTime()
        }
    }

    private func updateTime() {
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let components = calendar.dateComponents([.hour, .minute, .second], from: Date())
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)

        // 计算旋转角度（12小时制）
        let totalSeconds = hour * 3600 + minute * 60 + second
        rotation = totalSeconds / (12 * 3600) // 12小时一圈

        currentTime = Date()
    }

    private func formatTime(_ date: Date) -> String {
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }

    private func formatTimeWithPeriod(_ date: Date) -> String {
        let timeZone = TimeZone(identifier: contact.timeZoneIdentifier) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "a"
        return formatter.string(from: date).uppercased()
    }

    private func getTimeZoneDisplay(_ timeZoneIdentifier: String) -> String {
        let timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
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