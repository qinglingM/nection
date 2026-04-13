import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ContactStore.shared

    @State private var name: String = ""
    @State private var country: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var selectedTimeZone: TimeZone? = nil

    @State private var workStartTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 30)) ?? Date()
    @State private var workEndTime: Date = Calendar.current.date(from: DateComponents(hour: 17, minute: 45)) ?? Date()

    @State private var notifyWhenWorkStarts: Bool = false
    @State private var workHoursEnabled: Bool = true
    
    @State private var showingCountryPicker = false
    @State private var showingStatePicker = false
    @State private var showingCityPicker = false
    @State private var showingTimeZonePicker = false
    
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingStartTimeEditor = false
    @State private var showingEndTimeEditor = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Name", text: $name)
                            .foregroundColor(.white)
                        if name.isEmpty {
                            Text("*")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                } header: {
                    Text("基本信息")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "3A3A3C"))

                Section {
                    Button {
                        showingCountryPicker = true
                    } label: {
                        HStack {
                            HStack(spacing: 4) {
                                Text("COUNTRY")
                                    .foregroundColor(Color(hex: "8E8E93"))
                                if country.isEmpty {
                                    Text("*")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            Spacer()
                            Text(country.isEmpty ? "Select" : country)
                                .foregroundColor(country.isEmpty ? Color(hex: "636366") : .white)
                        }
                    }

                    Button {
                        showingStatePicker = true
                    } label: {
                        HStack {
                            Text("STATE")
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
                            HStack(spacing: 4) {
                                Text("CITY")
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                            Spacer()
                            Text(city.isEmpty ? "Optional" : city)
                                .foregroundColor(city.isEmpty ? Color(hex: "636366") : .white)
                        }
                    }

                    Button {
                        showingTimeZonePicker = true
                    } label: {
                        HStack {
                            Text("TIME ZONE")
                                .foregroundColor(Color(hex: "8E8E93"))
                            Spacer()
                            Text(selectedTimeZone?.identifier ?? "Not selected")
                                .foregroundColor(.white)
                        }
                    }
                } header: {
                    Text("Location")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "2C2C2E"))

                // 时间预览组件
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("START")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                Text(formatTime(workStartTime))
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Edit start time
                                showingStartTimeEditor = true
                                print("DEBUG: Opening START time editor")
                            }) {
                                Text("Edit")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(hex: "64D2FF"))
                            }
                        }
                        
                        Divider()
                            .background(Color(hex: "38383A"))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("END")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                Text(formatTime(workEndTime))
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Edit end time
                                showingEndTimeEditor = true
                                print("DEBUG: Opening END time editor")
                            }) {
                                Text("Edit")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(hex: "64D2FF"))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("WORK HOURS")
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .listRowBackground(Color(hex: "2C2C2E"))

                Section {
                    Toggle("Enable Work Hours", isOn: $workHoursEnabled)
                        .foregroundColor(.white)
                        .tint(Color(hex: "64D2FF"))
                        .onChange(of: workHoursEnabled) { enabled in
                            if !enabled {
                                notifyWhenWorkStarts = false
                            }
                        }
                    
                    if workHoursEnabled {
                        Toggle("Notify when work starts", isOn: $notifyWhenWorkStarts)
                            .foregroundColor(.white)
                            .tint(Color(hex: "30D158"))
                    }
                } header: {
                    Text("功能设置")
                        .foregroundColor(Color(hex: "8E8E93"))
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
                        if validateForm() {
                            saveContact()
                        } else {
                            showingValidationAlert = true
                        }
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                    .fontWeight(.semibold)
                }
            }
            .alert("Cannot Save", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .sheet(isPresented: $showingCountryPicker) {
                CountryPickerView(selectedCountry: $country, selectedState: $state, selectedCity: $city, selectedTimeZone: $selectedTimeZone)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingStartTimeEditor) {
                SimpleTimeEditor(
                    title: "Edit Start Time",
                    time: $workStartTime,
                    onDismiss: { showingStartTimeEditor = false }
                )
            }
            .sheet(isPresented: $showingEndTimeEditor) {
                SimpleTimeEditor(
                    title: "Edit End Time",
                    time: $workEndTime,
                    onDismiss: { showingEndTimeEditor = false }
                )
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

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: date)
        // print("DEBUG: formatTime called for \(date), returning: \(timeString)")
        return timeString
    }
    
    private func validateForm() -> Bool {
        if name.isEmpty {
            validationMessage = "Please enter contact name"
            return false
        }
        if country.isEmpty {
            validationMessage = "Please select a country"
            return false
        }
        return true
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
            timeZoneIdentifier: selectedTimeZone?.identifier ?? TimeZone.current.identifier,
            workStartTime: startComponents,
            workEndTime: endComponents,
            notifyWhenWorkStarts: notifyWhenWorkStarts,
            workHoursEnabled: workHoursEnabled
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
struct SimpleTimeEditor: View {
    let title: String
    @Binding var time: Date
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    title,
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .frame(maxHeight: 300)
                .background(Color(hex: "2C2C2E"))
                .cornerRadius(12)
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "1C1C1E"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }
}
