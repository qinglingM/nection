import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ContactStore.shared

    @State private var name: String = ""
    @State private var country: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var selectedTimeZone: TimeZone = TimeZone.current

    @State private var workStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var workEndTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()

    @State private var notifyWhenWorkStarts: Bool = false

    @State private var showingCountryPicker = false
    @State private var showingStatePicker = false
    @State private var showingCityPicker = false
    @State private var showingTimeZonePicker = false

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
                            Text(selectedTimeZone.identifier)
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
                    Toggle("Notify when work starts", isOn: $notifyWhenWorkStarts)
                        .foregroundColor(.white)
                        .tint(Color(hex: "30D158"))
                }
                .listRowBackground(Color(hex: "3A3A3C"))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .navigationTitle("Add Contact")
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
                CityPickerView(country: country, state: state, selectedCity: $city, selectedTimeZone: $selectedTimeZone)
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

        let contact = Contact(
            name: name,
            country: country,
            state: state,
            city: city,
            timeZoneIdentifier: selectedTimeZone.identifier,
            workStartTime: startComponents,
            workEndTime: endComponents,
            notifyWhenWorkStarts: notifyWhenWorkStarts
        )

        store.addContact(contact)

        if notifyWhenWorkStarts {
            NotificationManager.shared.scheduleWorkStartNotification(for: contact)
        }

        dismiss()
    }
}

#Preview {
    AddContactView()
        .preferredColorScheme(.dark)
}