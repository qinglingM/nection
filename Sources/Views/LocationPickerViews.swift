import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCountry: String
    @Binding var selectedState: String
    @Binding var selectedCity: String
    @Binding var selectedTimeZone: TimeZone?
    @State private var searchText = ""
    @State private var selectedContinent: String = "全部"
    
    let continents = ["全部", "亚洲", "欧洲", "北美洲", "南美洲", "非洲", "大洋洲"]
    
    // 国家到大洲的映射
    let countryToContinent: [String: String] = [
        // 亚洲
        "China": "亚洲",
        "Japan": "亚洲",
        "South Korea": "亚洲",
        "Singapore": "亚洲",
        "Malaysia": "亚洲",
        "Thailand": "亚洲",
        "Vietnam": "亚洲",
        "India": "亚洲",
        "Indonesia": "亚洲",
        "Philippines": "亚洲",
        "Turkey": "亚洲",
        "United Arab Emirates": "亚洲",
        "Saudi Arabia": "亚洲",
        "Israel": "亚洲",
        "Qatar": "亚洲",
        
        // 欧洲
        "United Kingdom": "欧洲",
        "Germany": "欧洲",
        "France": "欧洲",
        "Italy": "欧洲",
        "Spain": "欧洲",
        "Netherlands": "欧洲",
        "Switzerland": "欧洲",
        "Sweden": "欧洲",
        "Norway": "欧洲",
        "Denmark": "欧洲",
        "Finland": "欧洲",
        "Poland": "欧洲",
        "Russia": "欧洲",
        "Portugal": "欧洲",
        "Austria": "欧洲",
        "Belgium": "欧洲",
        "Ireland": "欧洲",
        
        // 北美洲
        "United States": "北美洲",
        "Canada": "北美洲",
        "Mexico": "北美洲",
        
        // 南美洲
        "Brazil": "南美洲",
        "Argentina": "南美洲",
        "Chile": "南美洲",
        "Colombia": "南美洲",
        "Peru": "南美洲",
        "Venezuela": "南美洲",
        
        // 非洲
        "South Africa": "非洲",
        "Egypt": "非洲",
        "Nigeria": "非洲",
        "Kenya": "非洲",
        "Morocco": "非洲",
        
        // 大洋洲
        "Australia": "大洋洲",
        "New Zealand": "大洋洲"
    ]
    
    var filteredCountries: [String] {
        let allCountries = getCountryNames()
        var filtered = allCountries
        
        // 按大洲筛选
        if selectedContinent != "全部" {
            filtered = filtered.filter { country in
                countryToContinent[country] == selectedContinent
            }
        }
        
        // 按搜索文本筛选
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
                            Text("未找到匹配的国家")
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
                                if let tz = getRecommendedTimeZone(for: country, city: "") {
                                    selectedTimeZone = tz
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
            .searchable(text: $searchText, prompt: "搜索国家")
            .tint(Color(hex: "64D2FF"))
            .navigationTitle("选择国家")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
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
            .navigationTitle("选择州/省")
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