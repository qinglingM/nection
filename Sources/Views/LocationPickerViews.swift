import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCountry: String
    @Binding var selectedState: String
    @Binding var selectedCity: String
    @Binding var selectedTimeZone: TimeZone
    @State private var searchText = ""

    var filteredCountries: [String] {
        if searchText.isEmpty {
            return getCountryNames()
        }
        return getCountryNames().filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCountries, id: \.self) { country in
                    Button {
                        selectedCountry = country
                        selectedState = ""
                        selectedCity = ""
                        if let tz = getRecommendedTimeZone(for: country, city: "") {
                            selectedTimeZone = tz
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text(country)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedCountry == country {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "64D2FF"))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color(hex: "2C2C2E"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .searchable(text: $searchText, prompt: "Search")
            .searchBarStyle(.minimal)
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "1C1C1E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
    }
}

struct StatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let country: String
    @Binding var selectedState: String
    @Binding var selectedCity: String
    @Binding var selectedTimeZone: TimeZone
    @State private var searchText = ""

    var filteredStates: [String] {
        if searchText.isEmpty {
            return getStates(for: country)
        }
        return getStates(for: country).filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredStates, id: \.self) { state in
                    Button {
                        selectedState = state
                        selectedCity = ""
                        dismiss()
                    } label: {
                        HStack {
                            Text(state)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedState == state {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "64D2FF"))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color(hex: "2C2C2E"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .searchable(text: $searchText, prompt: "Search")
            .searchBarStyle(.minimal)
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "1C1C1E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
    }
}

struct CityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let country: String
    let state: String
    @Binding var selectedCity: String
    @Binding var selectedTimeZone: TimeZone
    @State private var searchText = ""

    var filteredCities: [String] {
        if searchText.isEmpty {
            return getCities(for: country, state: state)
        }
        return getCities(for: country, state: state).filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCities, id: \.self) { city in
                    Button {
                        selectedCity = city
                        if let tz = getRecommendedTimeZone(for: country, city: city) {
                            selectedTimeZone = tz
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text(city)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedCity == city {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "64D2FF"))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color(hex: "2C2C2E"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .searchable(text: $searchText, prompt: "Search")
            .searchBarStyle(.minimal)
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "1C1C1E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
    }
}

struct TimeZonePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTimeZone: TimeZone
    @State private var searchText = ""

    var filteredTimeZones: [(identifier: String, displayName: String)] {
        if searchText.isEmpty {
            return allTimeZones
        }
        return allTimeZones.filter {
            $0.identifier.localizedCaseInsensitiveContains(searchText) ||
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTimeZones, id: \.identifier) { zone in
                    Button {
                        selectedTimeZone = TimeZone(identifier: zone.identifier) ?? TimeZone.current
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(zone.identifier)
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))
                                Text(zone.displayName)
                                    .foregroundColor(Color(hex: "8E8E93"))
                                    .font(.system(size: 12))
                            }
                            Spacer()
                            if selectedTimeZone.identifier == zone.identifier {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "64D2FF"))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color(hex: "2C2C2E"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "1C1C1E"))
            .searchable(text: $searchText, prompt: "Search time zones")
            .searchBarStyle(.minimal)
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "1C1C1E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
            }
        }
    }
}