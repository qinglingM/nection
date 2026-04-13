import Foundation

struct CountryData {
    let name: String
    let code: String
    let states: [String: [String]]
    let timeZones: [String]
}

let countriesData: [CountryData] = [
    CountryData(name: "United States", code: "US", states: [
        "California": ["Los Angeles", "San Francisco", "San Diego", "San Jose", "Sacramento"],
        "New York": ["New York City", "Buffalo", "Rochester", "Albany"],
        "Texas": ["Houston", "Dallas", "Austin", "San Antonio"],
        "Washington": ["Seattle", "Tacoma", "Spokane"],
        "Illinois": ["Chicago", "Aurora", "Naperville"],
        "Florida": ["Miami", "Orlando", "Tampa", "Jacksonville"],
        "Massachusetts": ["Boston", "Worcester", "Springfield"],
        "Georgia": ["Atlanta", "Augusta", "Savannah"],
        "Arizona": ["Phoenix", "Tucson", "Mesa"],
        "Colorado": ["Denver", "Colorado Springs", "Aurora"]
    ], timeZones: ["America/Los_Angeles", "America/Denver", "America/Chicago", "America/New_York"]),
    
    CountryData(name: "United Kingdom", code: "GB", states: [
        "England": ["London", "Manchester", "Birmingham", "Leeds", "Glasgow", "Liverpool", "Bristol"],
        "Scotland": ["Edinburgh", "Glasgow", "Aberdeen"],
        "Wales": ["Cardiff", "Swansea"],
        "Northern Ireland": ["Belfast"]
    ], timeZones: ["Europe/London"]),
    
    CountryData(name: "Germany", code: "DE", states: [
        "Bavaria": ["Munich", "Nuremberg"],
        "North Rhine-Westphalia": ["Cologne", "Dusseldorf", "Dortmund", "Essen"],
        "Baden-Wurttemberg": ["Stuttgart", "Mannheim", "Freiburg"],
        "Hesse": ["Frankfurt", "Wiesbaden"],
        "Berlin": ["Berlin"]
    ], timeZones: ["Europe/Berlin"]),
    
    CountryData(name: "France", code: "FR", states: [
        "Ile-de-France": ["Paris"],
        "Auvergne-Rhone-Alpes": ["Lyon", "Grenoble"],
        "Provence-Alpes-Cote d'Azur": ["Marseille", "Nice"],
        "Nouvelle-Aquitaine": ["Bordeaux", "Toulouse"],
        "Occitanie": ["Toulouse", "Montpellier"]
    ], timeZones: ["Europe/Paris"]),
    
    CountryData(name: "Japan", code: "JP", states: [
        "Tokyo": ["Tokyo"],
        "Osaka": ["Osaka"],
        "Kyoto": ["Kyoto"],
        "Aichi": ["Nagoya"],
        "Kanagawa": ["Yokohama"],
        "Fukuoka": ["Fukuoka"],
        "Hokkaido": ["Sapporo"]
    ], timeZones: ["Asia/Tokyo"]),
    
    CountryData(name: "China", code: "CN", states: [
        "Shanghai": ["Shanghai"],
        "Beijing": ["Beijing"],
        "Guangdong": ["Guangzhou", "Shenzhen", "Dongguan"],
        "Zhejiang": ["Hangzhou", "Ningbo", "Wenzhou"],
        "Jiangsu": ["Nanjing", "Suzhou", "Wuxi"],
        "Sichuan": ["Chengdu"]
    ], timeZones: ["Asia/Shanghai"]),
    
    CountryData(name: "Australia", code: "AU", states: [
        "New South Wales": ["Sydney", "Newcastle", "Wollongong"],
        "Victoria": ["Melbourne", "Geelong"],
        "Queensland": ["Brisbane", "Gold Coast", "Cairns"],
        "Western Australia": ["Perth"],
        "South Australia": ["Adelaide"]
    ], timeZones: ["Australia/Sydney", "Australia/Perth"]),
    
    CountryData(name: "Canada", code: "CA", states: [
        "Ontario": ["Toronto", "Ottawa", "Mississauga"],
        "Quebec": ["Montreal", "Quebec City"],
        "British Columbia": ["Vancouver", "Victoria"],
        "Alberta": ["Calgary", "Edmonton"]
    ], timeZones: ["America/Toronto", "America/Vancouver"]),
    
    CountryData(name: "India", code: "IN", states: [
        "Delhi": ["New Delhi"],
        "Maharashtra": ["Mumbai", "Pune"],
        "Karnataka": ["Bangalore", "Mysore"],
        "Tamil Nadu": ["Chennai"],
        "Telangana": ["Hyderabad"],
        "Gujarat": ["Ahmedabad", "Surat"]
    ], timeZones: ["Asia/Kolkata"]),
    
    CountryData(name: "Singapore", code: "SG", states: [
        "Central": ["Singapore"]
    ], timeZones: ["Asia/Singapore"]),
    
    CountryData(name: "South Korea", code: "KR", states: [
        "Seoul": ["Seoul"],
        "Busan": ["Busan"],
        "Incheon": ["Incheon"],
        "Daegu": ["Daegu"]
    ], timeZones: ["Asia/Seoul"]),
    
    CountryData(name: "Brazil", code: "BR", states: [
        "Sao Paulo": ["Sao Paulo"],
        "Rio de Janeiro": ["Rio de Janeiro"],
        "Minas Gerais": ["Belo Horizonte"],
        "Distrito Federal": ["Brasilia"]
    ], timeZones: ["America/Sao_Paulo"]),
    
    CountryData(name: "Netherlands", code: "NL", states: [
        "North Holland": ["Amsterdam", "Haarlem"],
        "South Holland": ["Rotterdam", "The Hague"],
        "Utrecht": ["Utrecht"]
    ], timeZones: ["Europe/Amsterdam"]),
    
    CountryData(name: "Switzerland", code: "CH", states: [
        "Zurich": ["Zurich"],
        "Geneva": ["Geneva"],
        "Bern": ["Bern"],
        "Basel": ["Basel"]
    ], timeZones: ["Europe/Zurich"]),
    
    CountryData(name: "Italy", code: "IT", states: [
        "Lombardy": ["Milan"],
        "Lazio": ["Rome"],
        "Veneto": ["Venice", "Verona"],
        "Tuscany": ["Florence"]
    ], timeZones: ["Europe/Rome"])
]

func getCountryNames() -> [String] {
    countriesData.map { $0.name }
}

func getStates(for country: String) -> [String] {
    countriesData.first { $0.name == country }?.states.keys.sorted() ?? []
}

func getCities(for country: String, state: String) -> [String] {
    countriesData.first { $0.name == country }?.states[state] ?? []
}

func getRecommendedTimeZone(for country: String, city: String) -> TimeZone? {
    guard let countryData = countriesData.first(where: { $0.name == country }) else {
        return TimeZone.current
    }
    
    if let firstZone = countryData.timeZones.first {
        return TimeZone(identifier: firstZone)
    }
    return TimeZone.current
}

let allTimeZones: [(identifier: String, displayName: String)] = {
    var zones: [(String, String)] = []
    for identifier in TimeZone.knownTimeZoneIdentifiers {
        let tz = TimeZone(identifier: identifier)
        let offset = tz?.secondsFromGMT() ?? 0
        let hours = offset / 3600
        let minutes = abs((offset % 3600) / 60)
        let sign = hours >= 0 ? "+" : ""
        let displayName = "\(identifier) (UTC\(sign)\(hours):\(String(format: "%02d", minutes)))"
        zones.append((identifier, displayName))
    }
    return zones.sorted { $0.1 < $1.1 }
}()