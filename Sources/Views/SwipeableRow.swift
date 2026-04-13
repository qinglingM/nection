import SwiftUI

struct SwipeableRow: View {
    let contact: Contact
    let onToggleReminder: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showingReminderFeedback = false
    
    private let buttonWidth: CGFloat = 60 // 按钮区域总宽度
    private let buttonHeight: CGFloat = 42 // 单个按钮高度
    private let spacing: CGFloat = 8 // 按钮间距
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // 背景按钮（垂直排列）
            HStack {
                Spacer()
                
                VStack(spacing: spacing) {
                    // 提醒按钮（上面）
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onToggleReminder()
                            showReminderFeedback()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(showingReminderFeedback ? 
                                    (contact.notifyWhenWorkStarts ? Color(hex: "8E8E93") : Color(hex: "FF9500")) :
                                    (contact.notifyWhenWorkStarts ? Color(hex: "FF9500") : Color(hex: "8E8E93")))
                                .frame(width: buttonHeight, height: buttonHeight)
                            
                            Image(systemName: contact.notifyWhenWorkStarts ? "bell.fill" : "bell")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .frame(width: buttonHeight + 20, height: buttonHeight + 20)
                        .contentShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(contact.notifyWhenWorkStarts ? "Turn off reminder" : "Turn on reminder")
                    .accessibilityHint("Toggle work start notification for \(contact.name)")
                    
                    // 删除按钮（下面）
                    Button(action: {
                        onDelete()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF3B30"))
                                .frame(width: buttonHeight, height: buttonHeight)
                            
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .frame(width: buttonHeight + 20, height: buttonHeight + 20)
                        .contentShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Delete contact")
                    .accessibilityHint("Delete \(contact.name) from your contacts")
                }
                .padding(.trailing, 20)
                .frame(width: buttonWidth)
            }
            
            // 卡片内容
            ZStack {
                ContactCardViewFinal(contact: contact)
                
                // 透明的 NavigationLink
                NavigationLink(destination: DetailView(contact: contact)) {
                    Color.clear
                }
                .opacity(0)
                .buttonStyle(PlainButtonStyle())
                .disabled(isSwiped) // 滑动时禁用导航
                .accessibilityLabel("View details for \(contact.name)")
                .accessibilityHint("Tap to view contact details and edit information")
            }
            .offset(x: offset)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Contact card for \(contact.name)")
            .accessibilityHint("Swipe left to reveal reminder and delete options")

            
            // 透明的收起区域（只覆盖卡片区域，不覆盖按钮区域）
            if isSwiped {
                HStack {
                    // 卡片区域（点击收起）
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                isSwiped = false
                            }
                        }
                        .accessibilityLabel("Close swipe actions")
                        .accessibilityHint("Tap to close reminder and delete options")
                        .accessibilityAddTraits(.isButton)
                    
                    // 按钮区域（不覆盖，让按钮可点击）
                    Color.clear
                        .frame(width: buttonWidth + 20) // 按钮区域宽度 + padding
                        .contentShape(Rectangle())
                        .allowsHitTesting(false) // 禁用点击检测，让按钮可点击
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .accessibilityElement(children: .contain)
        .accessibilityRepresentation {
            // 为辅助功能提供简化的表示
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text("Contact card with swipe actions")
                    .font(.caption)
            }
        }
    }
    
    private func showReminderFeedback() {
        showingReminderFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showingReminderFeedback = false
            }
        }
    }
}