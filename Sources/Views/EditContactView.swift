import SwiftUI

struct EditContactView: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ContactStore.shared

    @State private var name: String
    @State private var country: String
    @State private var state: String
    @State private var city: String
    @State private var selectedTimeZone: TimeZone?

    @State private var workStartTime: Date
    @State private var workEndTime: Date


    @State private var isPinned: Bool

    @State private var showingCountryPicker = false
    @State private var showingStatePicker = false
    @State private var showingCityPicker = false
    @State private var showingTimeZonePicker = false

    init(contact: Contact) {
        self.contact = contact
        _name = State(initialValue: contact.name)
        _country = State(initialValue: contact.country)
        _state = State(initialValue: contact.state)
        _city = State(initialValue: contact.city)
        _selectedTimeZone = State(initialValue: TimeZone(identifier: contact.timeZoneIdentifier))

        let calendar = Calendar.current
        _workStartTime = State(initialValue: calendar.date(from: contact.workStartTime) ?? Date())
        _workEndTime = State(initialValue: calendar.date(from: contact.workEndTime) ?? Date())


        _isPinned = State(initialValue: contact.isPinned)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "3A3A3C"))

                Section {
                    Button {
                        showingCountryPicker = true
                    } label: {
                        HStack {
                            Text("Country")
                                .foregroundColor(Color(hex: "8E8E93"))
                            Spacer()
                            Text(country.isEmpty ? "Select" : country)
                                .foregroundColor(country.isEmpty ? Color(hex: "636366") : .white)
                        }
                    }

                    Button {
                        showingStatePicker = true
                    } label: {
                        HStack {
                            Text("State / Province")
                                .foregroundColor(Color(hex: "8E8E93"))
                            Spacer()
                            Text(state.isEmpty ? "Select" : state)
                                .foregroundColor(state.isEmpty ? Color(hex: "636366") : .white)
                        }
                    }

                    Button {
                        showingCityPicker = true
                    } label: {
                        HStack {
                            Text("City")
                                .foregroundColor(Color(hex: "8E8E93"))
                            Spacer()
                            Text(city.isEmpty ? "Select" : city)
                                .foregroundColor(city.isEmpty ? Color(hex: "636366") : .white)
                        }
                    }

                    Button {
                        showingTimeZonePicker = true
                    } label: {
                        HStack {
                            Text("Time Zone")
                                .foregroundColor(Color(hex: "8E8E93"))
                            Spacer()
                            Text(selectedTimeZone?.identifier ?? contact.timeZoneIdentifier)
                                .foregroundColor(.white)
                        }
                    }
                } header: {
                    Text("Location")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "2C2C2E"))

                Section {
                    DatePicker("Work starts", selection: $workStartTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.white)
                        .colorScheme(.dark)

                    DatePicker("Work ends", selection: $workEndTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                } header: {
                    Text("Work Hours")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "2C2C2E"))

                Section {
                    Toggle("Pin contact", isOn: $isPinned)
                        .foregroundColor(.white)
                        .tint(Color(hex: "64D2FF"))
                }
                .listRowBackground(Color(hex: "3A3A3C"))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .navigationTitle("Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingCountryPicker) {
                CountryPickerView(selectedCountry: $country, selectedState: $state, selectedCity: $city, selectedTimeZone: $selectedTimeZone)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingStatePicker) {
                StatePickerView(country: country, selectedState: $state, selectedCity: $city, selectedTimeZone: $selectedTimeZone)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingCityPicker) {
                CityInputPickerView(country: country, state: state, selectedCity: $city, selectedTimeZone: $selectedTimeZone)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingTimeZonePicker) {
                TimeZonePickerView(selectedTimeZone: $selectedTimeZone)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !country.isEmpty && !city.isEmpty
    }

    private func saveContact() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: workStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: workEndTime)
        
        // 调试信息
        print("🔄 Saving contact: \(name)")
        print("📅 Start time: \(workStartTime), Components: \(startComponents)")
        print("📅 End time: \(workEndTime), Components: \(endComponents)")
        print("🌍 Time zone: \(selectedTimeZone?.identifier ?? "nil"), using: \(selectedTimeZone?.identifier ?? contact.timeZoneIdentifier)")

        var updatedContact = contact
        updatedContact.name = name
        updatedContact.country = country
        updatedContact.state = state
        updatedContact.city = city
        updatedContact.timeZoneIdentifier = selectedTimeZone?.identifier ?? contact.timeZoneIdentifier
        updatedContact.workStartTime = startComponents
        updatedContact.workEndTime = endComponents
        updatedContact.isPinned = isPinned

        store.updateContact(updatedContact)
        
        print("✅ Contact saved successfully: \(updatedContact.name)")

        dismiss()
    }
}

#Preview {
    EditContactView(contact: Contact(
        name: "Daniel",
        country: "United Kingdom",
        state: "England",
        city: "London",
        timeZoneIdentifier: "Europe/London",
        workStartTime: DateComponents(hour: 9, minute: 0),
        workEndTime: DateComponents(hour: 18, minute: 0),

        isPinned: false
    ))
    .preferredColorScheme(.dark)
}