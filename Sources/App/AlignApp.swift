import SwiftUI

@main
struct AlignApp: App {
    init() {
        // 应用启动时请求通知权限
        NotificationManager.shared.requestAuthorization()
        print("App started, notification authorization requested")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}