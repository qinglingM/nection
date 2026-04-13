import Foundation
import SwiftUI

@MainActor
class ContactStore: ObservableObject {
    static let shared = ContactStore()
    
    @Published private(set) var contacts: [Contact] = []
    
    private let saveKey = "SavedContacts"
    
    init() {
        loadContacts()
    }
    
    func addContact(_ contact: Contact) {
        contacts.append(contact)
        saveContacts()
    }
    
    func updateContact(_ contact: Contact) {
        print("🔄 ContactStore: Updating contact \(contact.name) (ID: \(contact.id))")
        
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
            print("✅ ContactStore: Contact updated successfully")
        } else {
            print("❌ ContactStore: Contact not found for update")
        }
    }
    
    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
    
    func sortedContacts() -> [Contact] {
        contacts.sorted { contact1, contact2 in
            if contact1.isPinned != contact2.isPinned {
                return contact1.isPinned
            }
            return contact1.sortOrder < contact2.sortOrder
        }
    }
    
    func moveContact(from source: IndexSet, to destination: Int) {
        var sorted = sortedContacts()
        sorted.move(fromOffsets: source, toOffset: destination)
        
        // 更新排序顺序
        for (index, contact) in sorted.enumerated() {
            if let originalIndex = contacts.firstIndex(where: { $0.id == contact.id }) {
                var updatedContact = contacts[originalIndex]
                updatedContact.sortOrder = index
                contacts[originalIndex] = updatedContact
            }
        }
        
        saveContacts()
        objectWillChange.send()
    }
    
    func reorderContacts(to newOrder: [Contact]) {
        // 更新所有联系人的排序顺序
        for (index, contact) in newOrder.enumerated() {
            if let originalIndex = contacts.firstIndex(where: { $0.id == contact.id }) {
                var updatedContact = contacts[originalIndex]
                updatedContact.sortOrder = index
                contacts[originalIndex] = updatedContact
            }
        }
        
        saveContacts()
        objectWillChange.send()
    }
    
    private func saveContacts() {
        print("💾 ContactStore: Saving \(contacts.count) contacts")
        
        do {
            let encoded = try JSONEncoder().encode(contacts)
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("✅ ContactStore: Saved successfully to UserDefaults")
        } catch {
            print("❌ ContactStore: Failed to encode contacts: \(error)")
            print("📋 Contacts data: \(contacts)")
        }
    }
    
    private func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Contact].self, from: data) else {
            // 如果没有保存的数据，创建一些示例数据
            createSampleContacts()
            return
        }
        contacts = decoded
    }
    
    private func createSampleContacts() {
        // 创建一些示例联系人
        let sampleContacts = [
            Contact(
                name: "纽约同事",
                country: "United States",
                state: "New York",
                city: "New York",
                timeZoneIdentifier: "America/New_York",
                workStartTime: DateComponents(hour: 9, minute: 0),
                workEndTime: DateComponents(hour: 17, minute: 0),
                isPinned: true
            ),
            Contact(
                name: "伦敦伙伴",
                country: "United Kingdom",
                state: "England",
                city: "London",
                timeZoneIdentifier: "Europe/London",
                workStartTime: DateComponents(hour: 9, minute: 0),
                workEndTime: DateComponents(hour: 17, minute: 0)
            ),
            Contact(
                name: "东京客户",
                country: "Japan",
                state: "Tokyo",
                city: "Tokyo",
                timeZoneIdentifier: "Asia/Tokyo",
                workStartTime: DateComponents(hour: 9, minute: 0),
                workEndTime: DateComponents(hour: 18, minute: 0)
            )
        ]
        
        contacts = sampleContacts
        saveContacts()
    }
}