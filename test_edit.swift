import SwiftUI

// 测试用的简单视图
struct TestContactListView: View {
    @State private var contacts = ["Alice", "Bob", "Charlie"]
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contacts, id: \.self) { contact in
                    Text(contact)
                        .padding(.vertical, 8)
                }
                .onDelete { indices in
                    contacts.remove(atOffsets: indices)
                }
                .onMove { indices, newOffset in
                    contacts.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        contacts.append("New Contact")
                    }
                }
            }
        }
    }
}