import SwiftUI

struct CityInputPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let country: String
    let state: String
    @Binding var selectedCity: String
    @Binding var selectedTimeZone: TimeZone?
    
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isTextFieldFocused: Bool
    
    // 获取预设城市列表
    private var presetCities: [String] {
        getCities(for: country, state: state)
    }
    
    // 过滤的城市列表
    private var filteredCities: [String] {
        if searchText.isEmpty {
            return []
        }
        return presetCities.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    // 是否显示预设城市列表
    private var showPresetCities: Bool {
        !searchText.isEmpty && !filteredCities.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部输入区域
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "8E8E93"))
                        
                        TextField("Enter city name", text: $searchText)
                            .foregroundColor(.white)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                submitCity()
                            }
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { oldValue, newValue in
                                isSearching = !newValue.isEmpty
                            }
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .foregroundColor(Color(hex: "64D2FF"))
                            .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "2C2C2E"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // 使用当前输入按钮
                    if !searchText.isEmpty && !presetCities.contains(searchText) {
                        Button(action: submitCity) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                
                                Text("Use \"\(searchText)\"")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Color(hex: "64D2FF"))
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "2C2C2E"))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .background(Color(hex: "1C1C1E"))
                
                // 预设城市列表
                if showPresetCities {
                    List {
                        Section {
                            ForEach(filteredCities, id: \.self) { city in
                                Button {
                                    selectPresetCity(city)
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
                        } header: {
                            Text("PRESET CITIES")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color(hex: "1C1C1E"))
                } else {
                    // 空状态或提示
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "2C2C2E"))
                        
                        VStack(spacing: 8) {
                            Text("Enter a city name")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Type to search preset cities or enter a custom city name")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "1C1C1E"))
                }
            }
            .navigationTitle("City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64D2FF"))
                }
            }
            .onAppear {
                // 初始化搜索文本
                searchText = selectedCity
                // 自动聚焦输入框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func submitCity() {
        guard !searchText.isEmpty else { return }
        selectedCity = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
    }
    
    private func selectPresetCity(_ city: String) {
        selectedCity = city
        if let tz = getRecommendedTimeZone(for: country, city: city) {
            selectedTimeZone = tz
        }
        dismiss()
    }
}