import SwiftUI

struct ContactListView: View {
    @StateObject private var store = ContactStore.shared
    @State private var isEditing = false
    @State private var showingAddContact = false

    var body: some View {
        List {
            ForEach(store.sortedContacts()) { contact in
                NavigationLink(destination: DetailView(contact: contact)) {
                    ContactCardView(contact: contact)
                }
                .listRowBackground(Color(hex: "3A3A3C"))
                .listRowSeparatorTint(Color(hex: "38383A"))
            }
            .onDelete(perform: deleteContacts)
            .onMove(perform: moveContacts)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "1C1C1E"))
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color(hex: "64D2FF"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddContact = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView()
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
    }

    private func deleteContacts(at offsets: IndexSet) {
        let sorted = store.sortedContacts()
        offsets.map { sorted[$0] }.forEach { store.deleteContact($0) }
    }

    private func moveContacts(from source: IndexSet, to destination: Int) {
        store.moveContact(from: source, to: destination)
    }
}

struct ContactCardView: View {
    let contact: Contact
    @State private var displayInfo: ContactDisplayInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(contact.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if contact.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "64D2FF"))
                }
            }

            Text(displayInfo?.locationDisplay ?? "\(contact.country) · \(contact.city)")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8E8E93"))

            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(displayInfo?.localTimeString ?? "--:--")
                        .font(.system(size: 48, weight: .200"))
                        .foregroundColor(.white)
                    
                    if let amPM = displayInfo?.amPM, !amPM.isEmpty {
                        Text(amPM)
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                }

                if let info = displayInfo {
                    StatusBadge(status: info.status)
                }

                Spacer()
            }

            Text(displayInfo?.suggestion ?? "")
                .font(.system(size: 15))
                .foregroundColor(suggestionColor)
        }
        .padding(.vertical, 8)
        .onAppear {
            displayInfo = TimeZoneManager.shared.getDisplayInfo(for: contact)
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            displayInfo = TimeZoneManager.shared.getDisplayInfo(for: contact)
        }
    }
    
    private var suggestionColor: Color {
        guard let info = displayInfo else { return Color(hex: "8E8E93") }
        switch info.status {
        case .working: return Color(hex: "30D158")
        case .beforeWork: return Color(hex: "64D2FF")
        case .afterHours, .weekend: return Color(hex: "8E8E93")
        }
    }
}

struct StatusBadge: View {
    let status: WorkStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(backgroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(foregroundColor)
            .cornerRadius(6)
    }

    var backgroundColor: Color {
        Color(hex: "1C1C1E")
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NavigationStack {
        ContactListView()
    }
    .preferredColorScheme(.dark)
}