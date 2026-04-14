import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCountry: String
    @Binding var selectedState: String
    @Binding var selectedCity: String
    @Binding var selectedTimeZone: TimeZone?
    @State private var searchText = ""
    @State private var selectedContinent: String = "All"
    
    let continents = ["All", "Asia", "Europe", "North America", "South America", "Africa", "Oceania"]
    
    // 国家到大洲的映射
    let countryToContinent: [String: String] = [
        // 亚洲
        "China": "Asia",
        "Japan": "Asia",
        "South Korea": "Asia",
        "Singapore": "Asia",
        "Malaysia": "Asia",
        "Thailand": "Asia",
        "Vietnam": "Asia",
        "India": "Asia",
        "Indonesia": "Asia",
        "Philippines": "Asia",
        "Turkey": "Asia",
        "United Arab Emirates": "Asia",
        "Saudi Arabia": "Asia",
        "Israel": "Asia",
        "Qatar": "Asia",
        "Taiwan (China)": "Asia",
        "Hong Kong (China)": "Asia",
        "Macau (China)": "Asia",
        "Pakistan": "Asia",
        "Bangladesh": "Asia",
        "Sri Lanka": "Asia",
        "Nepal": "Asia",
        "Iran": "Asia",
        "Iraq": "Asia",
        "Jordan": "Asia",
        "Kuwait": "Asia",
        "Lebanon": "Asia",
        "Oman": "Asia",
        "Syria": "Asia",
        "Yemen": "Asia",
        
        // Europe
        "United Kingdom": "Europe",
        "Germany": "Europe",
        "France": "Europe",
        "Italy": "Europe",
        "Spain": "Europe",
        "Netherlands": "Europe",
        "Switzerland": "Europe",
        "Sweden": "Europe",
        "Norway": "Europe",
        "Denmark": "Europe",
        "Finland": "Europe",
        "Poland": "Europe",
        "Russia": "Europe",
        "Portugal": "Europe",
        "Austria": "Europe",
        "Belgium": "Europe",
        "Ireland": "Europe",
        "Ukraine": "Europe",
        "Czech Republic": "Europe",
        "Hungary": "Europe",
        "Romania": "Europe",
        "Greece": "Europe",
        "Bulgaria": "Europe",
        "Croatia": "Europe",
        "Serbia": "Europe",
        "Slovakia": "Europe",
        "Slovenia": "Europe",
        
        // North America
        "United States": "North America",
        "Canada": "North America",
        "Mexico": "North America",
        "Cuba": "North America",
        "Dominican Republic": "North America",
        "Jamaica": "North America",
        "Puerto Rico": "North America",
        "Costa Rica": "North America",
        "Panama": "North America",
        
        // South America
        "Brazil": "South America",
        "Argentina": "South America",
        "Chile": "South America",
        "Colombia": "South America",
        "Peru": "South America",
        "Venezuela": "South America",
        "Uruguay": "South America",
        "Paraguay": "South America",
        "Bolivia": "South America",
        "Ecuador": "South America",
        
        // Africa
        "South Africa": "Africa",
        "Egypt": "Africa",
        "Nigeria": "Africa",
        "Kenya": "Africa",
        "Morocco": "Africa",
        "Algeria": "Africa",
        "Angola": "Africa",
        "Ethiopia": "Africa",
        "Ghana": "Africa",
        "Ivory Coast": "Africa",
        "Tanzania": "Africa",
        "Uganda": "Africa",
        "Zambia": "Africa",
        "Zimbabwe": "Africa",
        
        // Oceania
        "Australia": "Oceania",
        "New Zealand": "Oceania",
        "Fiji": "Oceania",
        "Papua New Guinea": "Oceania"
    ]
    
    // Country to timezone mapping (capital city timezone)
    let countryToTimeZone: [String: String] = [
        // Asia
        "China": "Asia/Shanghai",
        "Japan": "Asia/Tokyo",
        "South Korea": "Asia/Seoul",
        "Singapore": "Asia/Singapore",
        "Malaysia": "Asia/Kuala_Lumpur",
        "Thailand": "Asia/Bangkok",
        "Vietnam": "Asia/Ho_Chi_Minh",
        "India": "Asia/Kolkata",
        "Indonesia": "Asia/Jakarta",
        "Philippines": "Asia/Manila",
        "Turkey": "Europe/Istanbul",
        "United Arab Emirates": "Asia/Dubai",
        "Saudi Arabia": "Asia/Riyadh",
        "Israel": "Asia/Jerusalem",
        "Qatar": "Asia/Qatar",
        "Taiwan (China)": "Asia/Taipei",
        "Hong Kong (China)": "Asia/Hong_Kong",
        "Macau (China)": "Asia/Macau",
        "Pakistan": "Asia/Karachi",
        "Bangladesh": "Asia/Dhaka",
        "Sri Lanka": "Asia/Colombo",
        "Nepal": "Asia/Kathmandu",
        "Iran": "Asia/Tehran",
        "Iraq": "Asia/Baghdad",
        "Jordan": "Asia/Amman",
        "Kuwait": "Asia/Kuwait",
        "Lebanon": "Asia/Beirut",
        "Oman": "Asia/Muscat",
        "Syria": "Asia/Damascus",
        "Yemen": "Asia/Aden",
        
        // Europe
        "United Kingdom": "Europe/London",
        "Germany": "Europe/Berlin",
        "France": "Europe/Paris",
        "Italy": "Europe/Rome",
        "Spain": "Europe/Madrid",
        "Netherlands": "Europe/Amsterdam",
        "Switzerland": "Europe/Zurich",
        "Sweden": "Europe/Stockholm",
        "Norway": "Europe/Oslo",
        "Denmark": "Europe/Copenhagen",
        "Finland": "Europe/Helsinki",
        "Poland": "Europe/Warsaw",
        "Russia": "Europe/Moscow",
        "Portugal": "Europe/Lisbon",
        "Austria": "Europe/Vienna",
        "Belgium": "Europe/Brussels",
        "Ireland": "Europe/Dublin",
        "Ukraine": "Europe/Kiev",
        "Czech Republic": "Europe/Prague",
        "Hungary": "Europe/Budapest",
        "Romania": "Europe/Bucharest",
        "Greece": "Europe/Athens",
        "Bulgaria": "Europe/Sofia",
        "Croatia": "Europe/Zagreb",
        "Serbia": "Europe/Belgrade",
        "Slovakia": "Europe/Bratislava",
        "Slovenia": "Europe/Ljubljana",
        
        // North America
        "United States": "America/New_York",
        "Canada": "America/Toronto",
        "Mexico": "America/Mexico_City",
        "Cuba": "America/Havana",
        "Dominican Republic": "America/Santo_Domingo",
        "Jamaica": "America/Jamaica",
        "Puerto Rico": "America/Puerto_Rico",
        "Costa Rica": "America/Costa_Rica",
        "Panama": "America/Panama",
        
        // South America
        "Brazil": "America/Sao_Paulo",
        "Argentina": "America/Argentina/Buenos_Aires",
        "Chile": "America/Santiago",
        "Colombia": "America/Bogota",
        "Peru": "America/Lima",
        "Venezuela": "America/Caracas",
        "Uruguay": "America/Montevideo",
        "Paraguay": "America/Asuncion",
        "Bolivia": "America/La_Paz",
        "Ecuador": "America/Guayaquil",
        
        // Africa
        "South Africa": "Africa/Johannesburg",
        "Egypt": "Africa/Cairo",
        "Nigeria": "Africa/Lagos",
        "Kenya": "Africa/Nairobi",
        "Morocco": "Africa/Casablanca",
        "Algeria": "Africa/Algiers",
        "Angola": "Africa/Luanda",
        "Ethiopia": "Africa/Addis_Ababa",
        "Ghana": "Africa/Accra",
        "Ivory Coast": "Africa/Abidjan",
        "Tanzania": "Africa/Dar_es_Salaam",
        "Uganda": "Africa/Kampala",
        "Zambia": "Africa/Lusaka",
        "Zimbabwe": "Africa/Harare",
        
        // Oceania
        "Australia": "Australia/Sydney",
        "New Zealand": "Pacific/Auckland",
        "Fiji": "Pacific/Fiji",
        "Papua New Guinea": "Pacific/Port_Moresby"
    ]
    
    var filteredCountries: [String] {
        let allCountries = countryToContinent.keys.sorted()
        var filtered = allCountries
        
        // Filter by continent
        if selectedContinent != "All" {
            filtered = filtered.filter { country in
                countryToContinent[country] == selectedContinent
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filtered
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 大洲筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(continents, id: \.self) { continent in
                            Button {
                                selectedContinent = continent
                            } label: {
                                Text(continent)
                                    .font(.system(size: 14, weight: selectedContinent == continent ? .semibold : .regular))
                                    .foregroundColor(selectedContinent == continent ? Color(hex: "64D2FF") : Color(hex: "8E8E93"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedContinent == continent ? Color(hex: "64D2FF").opacity(0.2) : Color(hex: "2C2C2E"))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(hex: "1C1C1E"))
                
                Divider()
                    .background(Color(hex: "38383A"))
                
                // 国家列表
                List {
                    if filteredCountries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "globe")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "8E8E93"))
                            Text("No matching countries found")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .listRowBackground(Color(hex: "1C1C1E"))
                    } else {
                        ForEach(filteredCountries, id: \.self) { country in
                            Button {
                                selectedCountry = country
                                selectedState = ""
                                selectedCity = ""
                                // Set timezone based on country
                                if let timeZoneId = countryToTimeZone[country] {
                                    selectedTimeZone = TimeZone(identifier: timeZoneId)
                                } else {
                                    // Fallback to getRecommendedTimeZone for countries in countriesData
                                    if let tz = getRecommendedTimeZone(for: country, city: "") {
                                        selectedTimeZone = tz
                                    }
                                }
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(country)
                                            .foregroundColor(.white)
                                            .font(.system(size: 17))
                                        
                                        if let continent = countryToContinent[country] {
                                            Text(continent)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(hex: "8E8E93"))
                                        }
                                    }
                                    
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
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(hex: "1C1C1E"))
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
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
    @Binding var selectedTimeZone: TimeZone?
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
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select State/Province")
            .navigationBarTitleDisplayMode(.inline)
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
    @Binding var selectedTimeZone: TimeZone?
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
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
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
    @Binding var selectedTimeZone: TimeZone?
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
                        selectedTimeZone = TimeZone(identifier: zone.identifier)
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
                            if let selected = selectedTimeZone, selected.identifier == zone.identifier {
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
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("Select Time Zone")
            .navigationBarTitleDisplayMode(.inline)
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