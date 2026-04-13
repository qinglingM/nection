import Foundation

struct CountryData {
    let name: String
    let code: String
    let states: [String: [String]]
    let timeZones: [String]
}

let countriesData: [CountryData] = [
    // 亚洲
    CountryData(name: "China", code: "CN", states: [
        "Beijing": ["Beijing"],
        "Shanghai": ["Shanghai"],
        "Guangdong": ["Guangzhou", "Shenzhen", "Dongguan"],
        "Zhejiang": ["Hangzhou", "Ningbo", "Wenzhou"],
        "Jiangsu": ["Nanjing", "Suzhou", "Wuxi"],
        "Sichuan": ["Chengdu", "Chongqing"],
        "Hubei": ["Wuhan"],
        "Shaanxi": ["Xi'an"],
        "Liaoning": ["Shenyang", "Dalian"],
        "Fujian": ["Xiamen", "Fuzhou"]
    ], timeZones: ["Asia/Shanghai"]),
    
    CountryData(name: "Japan", code: "JP", states: [
        "Tokyo": ["Tokyo"],
        "Osaka": ["Osaka"],
        "Kyoto": ["Kyoto"],
        "Hokkaido": ["Sapporo"],
        "Kanagawa": ["Yokohama", "Kawasaki"],
        "Aichi": ["Nagoya"],
        "Fukuoka": ["Fukuoka"],
        "Hiroshima": ["Hiroshima"]
    ], timeZones: ["Asia/Tokyo"]),
    
    CountryData(name: "South Korea", code: "KR", states: [
        "Seoul": ["Seoul"],
        "Busan": ["Busan"],
        "Incheon": ["Incheon"],
        "Daegu": ["Daegu"],
        "Gwangju": ["Gwangju"],
        "Daejeon": ["Daejeon"],
        "Ulsan": ["Ulsan"],
        "Gyeonggi": ["Suwon", "Seongnam"]
    ], timeZones: ["Asia/Seoul"]),
    
    CountryData(name: "Singapore", code: "SG", states: [
        "Central Region": ["Singapore"]
    ], timeZones: ["Asia/Singapore"]),
    
    CountryData(name: "Malaysia", code: "MY", states: [
        "Kuala Lumpur": ["Kuala Lumpur"],
        "Selangor": ["Shah Alam", "Petaling Jaya"],
        "Penang": ["George Town"],
        "Johor": ["Johor Bahru"],
        "Sabah": ["Kota Kinabalu"],
        "Sarawak": ["Kuching"]
    ], timeZones: ["Asia/Kuala_Lumpur"]),
    
    CountryData(name: "Thailand", code: "TH", states: [
        "Bangkok": ["Bangkok"],
        "Chiang Mai": ["Chiang Mai"],
        "Phuket": ["Phuket"],
        "Nonthaburi": ["Nonthaburi"],
        "Samut Prakan": ["Samut Prakan"]
    ], timeZones: ["Asia/Bangkok"]),
    
    CountryData(name: "Vietnam", code: "VN", states: [
        "Hanoi": ["Hanoi"],
        "Ho Chi Minh City": ["Ho Chi Minh City"],
        "Da Nang": ["Da Nang"],
        "Hai Phong": ["Hai Phong"],
        "Can Tho": ["Can Tho"]
    ], timeZones: ["Asia/Ho_Chi_Minh"]),
    
    CountryData(name: "India", code: "IN", states: [
        "Delhi": ["New Delhi"],
        "Maharashtra": ["Mumbai", "Pune"],
        "Karnataka": ["Bangalore"],
        "Tamil Nadu": ["Chennai"],
        "Telangana": ["Hyderabad"],
        "Gujarat": ["Ahmedabad"],
        "West Bengal": ["Kolkata"],
        "Uttar Pradesh": ["Lucknow", "Kanpur"]
    ], timeZones: ["Asia/Kolkata"]),
    
    CountryData(name: "Indonesia", code: "ID", states: [
        "Jakarta": ["Jakarta"],
        "West Java": ["Bandung"],
        "Central Java": ["Semarang"],
        "East Java": ["Surabaya"],
        "Bali": ["Denpasar"],
        "North Sumatra": ["Medan"]
    ], timeZones: ["Asia/Jakarta"]),
    
    CountryData(name: "Philippines", code: "PH", states: [
        "Metro Manila": ["Manila", "Quezon City"],
        "Cebu": ["Cebu City"],
        "Davao": ["Davao City"],
        "Calabarzon": ["Antipolo", "Bacoor"]
    ], timeZones: ["Asia/Manila"]),
    
    CountryData(name: "Turkey", code: "TR", states: [
        "Istanbul": ["Istanbul"],
        "Ankara": ["Ankara"],
        "Izmir": ["Izmir"],
        "Bursa": ["Bursa"],
        "Antalya": ["Antalya"]
    ], timeZones: ["Europe/Istanbul"]),
    
    CountryData(name: "United Arab Emirates", code: "AE", states: [
        "Dubai": ["Dubai"],
        "Abu Dhabi": ["Abu Dhabi"],
        "Sharjah": ["Sharjah"],
        "Ajman": ["Ajman"]
    ], timeZones: ["Asia/Dubai"]),
    
    CountryData(name: "Saudi Arabia", code: "SA", states: [
        "Riyadh": ["Riyadh"],
        "Jeddah": ["Jeddah"],
        "Mecca": ["Mecca"],
        "Medina": ["Medina"],
        "Dammam": ["Dammam"]
    ], timeZones: ["Asia/Riyadh"]),
    
    // 欧洲
    CountryData(name: "United Kingdom", code: "GB", states: [
        "England": ["London", "Manchester", "Birmingham", "Leeds", "Liverpool", "Bristol", "Sheffield"],
        "Scotland": ["Edinburgh", "Glasgow", "Aberdeen", "Dundee"],
        "Wales": ["Cardiff", "Swansea", "Newport"],
        "Northern Ireland": ["Belfast", "Derry"]
    ], timeZones: ["Europe/London"]),
    
    CountryData(name: "Germany", code: "DE", states: [
        "Berlin": ["Berlin"],
        "Bavaria": ["Munich", "Nuremberg", "Augsburg"],
        "North Rhine-Westphalia": ["Cologne", "Dusseldorf", "Dortmund", "Essen", "Duisburg"],
        "Baden-Wurttemberg": ["Stuttgart", "Mannheim", "Freiburg", "Karlsruhe"],
        "Hesse": ["Frankfurt", "Wiesbaden", "Kassel"],
        "Lower Saxony": ["Hannover", "Braunschweig", "Osnabruck"],
        "Saxony": ["Dresden", "Leipzig", "Chemnitz"]
    ], timeZones: ["Europe/Berlin"]),
    
    CountryData(name: "France", code: "FR", states: [
        "Ile-de-France": ["Paris", "Versailles", "Boulogne-Billancourt"],
        "Auvergne-Rhone-Alpes": ["Lyon", "Grenoble", "Saint-Etienne"],
        "Provence-Alpes-Cote d'Azur": ["Marseille", "Nice", "Toulon"],
        "Nouvelle-Aquitaine": ["Bordeaux", "Limoges", "Poitiers"],
        "Occitanie": ["Toulouse", "Montpellier", "Nimes"],
        "Hauts-de-France": ["Lille", "Amiens", "Roubaix"],
        "Grand Est": ["Strasbourg", "Nancy", "Metz"]
    ], timeZones: ["Europe/Paris"]),
    
    CountryData(name: "Italy", code: "IT", states: [
        "Lombardy": ["Milan", "Brescia", "Monza", "Bergamo"],
        "Lazio": ["Rome", "Latina", "Frosinone"],
        "Veneto": ["Venice", "Verona", "Padua", "Vicenza"],
        "Tuscany": ["Florence", "Pisa", "Siena", "Livorno"],
        "Campania": ["Naples", "Salerno", "Caserta"],
        "Emilia-Romagna": ["Bologna", "Modena", "Parma", "Reggio Emilia"],
        "Piedmont": ["Turin", "Alessandria", "Novara"]
    ], timeZones: ["Europe/Rome"]),
    
    CountryData(name: "Spain", code: "ES", states: [
        "Madrid": ["Madrid"],
        "Catalonia": ["Barcelona", "Tarragona", "Lleida"],
        "Andalusia": ["Seville", "Malaga", "Granada", "Cordoba"],
        "Valencian Community": ["Valencia", "Alicante", "Castellon"],
        "Basque Country": ["Bilbao", "San Sebastian", "Vitoria-Gasteiz"],
        "Galicia": ["A Coruna", "Vigo", "Santiago de Compostela"]
    ], timeZones: ["Europe/Madrid"]),
    
    CountryData(name: "Netherlands", code: "NL", states: [
        "North Holland": ["Amsterdam", "Haarlem", "Zaandam"],
        "South Holland": ["Rotterdam", "The Hague", "Leiden", "Dordrecht"],
        "Utrecht": ["Utrecht", "Amersfoort"],
        "North Brabant": ["Eindhoven", "Tilburg", "Breda"],
        "Gelderland": ["Arnhem", "Nijmegen", "Apeldoorn"]
    ], timeZones: ["Europe/Amsterdam"]),
    
    CountryData(name: "Switzerland", code: "CH", states: [
        "Zurich": ["Zurich", "Winterthur"],
        "Geneva": ["Geneva"],
        "Bern": ["Bern", "Thun", "Biel"],
        "Basel": ["Basel"],
        "Vaud": ["Lausanne", "Montreux"],
        "Lucerne": ["Lucerne"],
        "St. Gallen": ["St. Gallen"]
    ], timeZones: ["Europe/Zurich"]),
    
    CountryData(name: "Sweden", code: "SE", states: [
        "Stockholm": ["Stockholm"],
        "Vastra Gotaland": ["Gothenburg", "Borås"],
        "Skane": ["Malmo", "Lund", "Helsingborg"],
        "Uppsala": ["Uppsala"],
        "Ostergotland": ["Linkoping", "Norrkoping"]
    ], timeZones: ["Europe/Stockholm"]),
    
    CountryData(name: "Norway", code: "NO", states: [
        "Oslo": ["Oslo"],
        "Rogaland": ["Stavanger", "Sandnes"],
        "Hordaland": ["Bergen"],
        "Trondelag": ["Trondheim"],
        "Troms og Finnmark": ["Tromso"]
    ], timeZones: ["Europe/Oslo"]),
    
    CountryData(name: "Denmark", code: "DK", states: [
        "Capital Region": ["Copenhagen", "Frederiksberg"],
        "Zealand": ["Roskilde", "Helsingor"],
        "South Denmark": ["Odense", "Esbjerg"],
        "Central Denmark": ["Aarhus", "Randers"]
    ], timeZones: ["Europe/Copenhagen"]),
    
    CountryData(name: "Finland", code: "FI", states: [
        "Uusimaa": ["Helsinki", "Espoo", "Vantaa"],
        "Pirkanmaa": ["Tampere"],
        "North Ostrobothnia": ["Oulu"],
        "Southwest Finland": ["Turku"],
        "Lapland": ["Rovaniemi"]
    ], timeZones: ["Europe/Helsinki"]),
    
    CountryData(name: "Poland", code: "PL", states: [
        "Masovian": ["Warsaw", "Radom"],
        "Lesser Poland": ["Krakow", "Tarnow"],
        "Silesian": ["Katowice", "Czestochowa", "Sosnowiec"],
        "Greater Poland": ["Poznan", "Kalisz"],
        "Lower Silesian": ["Wroclaw", "Legnica"]
    ], timeZones: ["Europe/Warsaw"]),
    
    CountryData(name: "Russia", code: "RU", states: [
        "Moscow": ["Moscow"],
        "Saint Petersburg": ["Saint Petersburg"],
        "Novosibirsk Oblast": ["Novosibirsk"],
        "Yekaterinburg": ["Yekaterinburg"],
        "Nizhny Novgorod Oblast": ["Nizhny Novgorod"],
        "Kazan": ["Kazan"],
        "Chelyabinsk Oblast": ["Chelyabinsk"],
        "Omsk Oblast": ["Omsk"]
    ], timeZones: ["Europe/Moscow", "Asia/Yekaterinburg", "Asia/Novosibirsk", "Asia/Irkutsk", "Asia/Vladivostok"]),
    
    CountryData(name: "Portugal", code: "PT", states: [
        "Lisbon": ["Lisbon"],
        "Porto": ["Porto"],
        "Braga": ["Braga"],
        "Setubal": ["Setubal"],
        "Aveiro": ["Aveiro"]
    ], timeZones: ["Europe/Lisbon"]),
    
    CountryData(name: "Austria", code: "AT", states: [
        "Vienna": ["Vienna"],
        "Upper Austria": ["Linz", "Wels"],
        "Styria": ["Graz"],
        "Tyrol": ["Innsbruck"],
        "Salzburg": ["Salzburg"]
    ], timeZones: ["Europe/Vienna"]),
    
    CountryData(name: "Belgium", code: "BE", states: [
        "Brussels": ["Brussels"],
        "Antwerp": ["Antwerp"],
        "East Flanders": ["Ghent"],
        "West Flanders": ["Bruges", "Ostend"],
        "Liege": ["Liege"]
    ], timeZones: ["Europe/Brussels"]),
    
    CountryData(name: "Ireland", code: "IE", states: [
        "Leinster": ["Dublin", "Dun Laoghaire"],
        "Munster": ["Cork", "Limerick", "Waterford"],
        "Connacht": ["Galway", "Sligo"],
        "Ulster": ["Belfast", "Derry"]
    ], timeZones: ["Europe/Dublin"]),
    
    // 北美洲
    CountryData(name: "United States", code: "US", states: [
        "California": ["Los Angeles", "San Francisco", "San Diego", "San Jose", "Sacramento", "Fresno", "Long Beach"],
        "New York": ["New York City", "Buffalo", "Rochester", "Albany", "Syracuse"],
        "Texas": ["Houston", "Dallas", "Austin", "San Antonio", "Fort Worth", "El Paso"],
        "Washington": ["Seattle", "Tacoma", "Spokane", "Vancouver"],
        "Illinois": ["Chicago", "Aurora", "Naperville", "Joliet"],
        "Florida": ["Miami", "Orlando", "Tampa", "Jacksonville", "Tallahassee"],
        "Massachusetts": ["Boston", "Worcester", "Springfield", "Cambridge"],
        "Georgia": ["Atlanta", "Augusta", "Savannah", "Athens"],
        "Arizona": ["Phoenix", "Tucson", "Mesa", "Chandler"],
        "Colorado": ["Denver", "Colorado Springs", "Aurora", "Fort Collins"],
        "Pennsylvania": ["Philadelphia", "Pittsburgh", "Allentown", "Erie"],
        "Michigan": ["Detroit", "Grand Rapids", "Warren", "Sterling Heights"],
        "Ohio": ["Columbus", "Cleveland", "Cincinnati", "Toledo"],
        "North Carolina": ["Charlotte", "Raleigh", "Greensboro", "Durham"],
        "New Jersey": ["Newark", "Jersey City", "Paterson", "Elizabeth"]
    ], timeZones: ["America/Los_Angeles", "America/Denver", "America/Chicago", "America/New_York", "America/Anchorage", "Pacific/Honolulu"]),
    
    CountryData(name: "Canada", code: "CA", states: [
        "Ontario": ["Toronto", "Ottawa", "Mississauga", "Brampton", "Hamilton"],
        "Quebec": ["Montreal", "Quebec City", "Laval", "Gatineau"],
        "British Columbia": ["Vancouver", "Surrey", "Burnaby", "Richmond"],
        "Alberta": ["Calgary", "Edmonton", "Red Deer", "Lethbridge"],
        "Manitoba": ["Winnipeg", "Brandon"],
        "Saskatchewan": ["Saskatoon", "Regina"],
        "Nova Scotia": ["Halifax", "Sydney"],
        "New Brunswick": ["Fredericton", "Saint John", "Moncton"]
    ], timeZones: ["America/Toronto", "America/Vancouver", "America/Edmonton", "America/Winnipeg", "America/Halifax"]),
    
    CountryData(name: "Mexico", code: "MX", states: [
        "Mexico City": ["Mexico City"],
        "Jalisco": ["Guadalajara", "Zapopan"],
        "Nuevo Leon": ["Monterrey", "San Nicolas de los Garza"],
        "Baja California": ["Tijuana", "Mexicali"],
        "Puebla": ["Puebla", "Tehuacan"]
    ], timeZones: ["America/Mexico_City"]),
    
    // 南美洲
    CountryData(name: "Brazil", code: "BR", states: [
        "Sao Paulo": ["Sao Paulo", "Guarulhos", "Campinas"],
        "Rio de Janeiro": ["Rio de Janeiro", "Niteroi", "Duque de Caxias"],
        "Minas Gerais": ["Belo Horizonte", "Uberlandia", "Contagem"],
        "Distrito Federal": ["Brasilia"],
        "Rio Grande do Sul": ["Porto Alegre", "Caxias do Sul"],
        "Bahia": ["Salvador", "Feira de Santana"],
        "Parana": ["Curitiba", "Londrina", "Maringa"]
    ], timeZones: ["America/Sao_Paulo"]),
    
    CountryData(name: "Argentina", code: "AR", states: [
        "Buenos Aires": ["Buenos Aires", "La Plata", "Mar del Plata"],
        "Cordoba": ["Cordoba", "Rio Cuarto"],
        "Santa Fe": ["Rosario", "Santa Fe"],
        "Mendoza": ["Mendoza", "San Rafael"],
        "Tucuman": ["San Miguel de Tucuman"]
    ], timeZones: ["America/Argentina/Buenos_Aires"]),
    
    CountryData(name: "Chile", code: "CL", states: [
        "Santiago Metropolitan": ["Santiago", "Puente Alto", "Maipu"],
        "Valparaiso": ["Valparaiso", "Vina del Mar"],
        "Biobio": ["Concepcion", "Talcahuano"],
        "La Araucania": ["Temuco", "Padre las Casas"]
    ], timeZones: ["America/Santiago"]),
    
    CountryData(name: "Colombia", code: "CO", states: [
        "Bogota": ["Bogota"],
        "Antioquia": ["Medellin", "Bello", "Itagui"],
        "Valle del Cauca": ["Cali", "Buenaventura"],
        "Atlantico": ["Barranquilla", "Soledad"],
        "Bolivar": ["Cartagena"]
    ], timeZones: ["America/Bogota"]),
    
    CountryData(name: "Peru", code: "PE", states: [
        "Lima": ["Lima", "Callao"],
        "Arequipa": ["Arequipa"],
        "La Libertad": ["Trujillo", "Chepen"],
        "Piura": ["Piura", "Sullana"],
        "Lambayeque": ["Chiclayo"]
    ], timeZones: ["America/Lima"]),
    
    CountryData(name: "Venezuela", code: "VE", states: [
        "Capital District": ["Caracas"],
        "Zulia": ["Maracaibo", "Cabimas"],
        "Miranda": ["Los Teques", "Petare"],
        "Carabobo": ["Valencia", "Puerto Cabello"],
        "Lara": ["Barquisimeto"]
    ], timeZones: ["America/Caracas"]),
    
    // 非洲
    CountryData(name: "South Africa", code: "ZA", states: [
        "Gauteng": ["Johannesburg", "Pretoria", "Soweto"],
        "Western Cape": ["Cape Town", "Stellenbosch"],
        "KwaZulu-Natal": ["Durban", "Pietermaritzburg"],
        "Eastern Cape": ["Port Elizabeth", "East London"]
    ], timeZones: ["Africa/Johannesburg"]),
    
    CountryData(name: "Egypt", code: "EG", states: [
        "Cairo": ["Cairo", "Giza"],
        "Alexandria": ["Alexandria"],
        "Giza": ["Giza", "6th of October City"],
        "Shubra El-Kheima": ["Shubra El-Kheima"],
        "Port Said": ["Port Said"]
    ], timeZones: ["Africa/Cairo"]),
    
    CountryData(name: "Nigeria", code: "NG", states: [
        "Lagos": ["Lagos", "Ikeja"],
        "Kano": ["Kano"],
        "Abuja Federal Capital Territory": ["Abuja"],
        "Kaduna": ["Kaduna"],
        "Rivers": ["Port Harcourt"]
    ], timeZones: ["Africa/Lagos"]),
    
    CountryData(name: "Kenya", code: "KE", states: [
        "Nairobi": ["Nairobi"],
        "Mombasa": ["Mombasa"],
        "Kisumu": ["Kisumu"],
        "Nakuru": ["Nakuru"],
        "Eldoret": ["Eldoret"]
    ], timeZones: ["Africa/Nairobi"]),
    
    CountryData(name: "Morocco", code: "MA", states: [
        "Casablanca-Settat": ["Casablanca", "Mohammedia"],
        "Rabat-Sale-Kenitra": ["Rabat", "Sale", "Kenitra"],
        "Fes-Meknes": ["Fes", "Meknes"],
        "Marrakesh-Safi": ["Marrakesh", "Safi"]
    ], timeZones: ["Africa/Casablanca"]),
    
    // 大洋洲
    CountryData(name: "Australia", code: "AU", states: [
        "New South Wales": ["Sydney", "Newcastle", "Wollongong"],
        "Victoria": ["Melbourne", "Geelong", "Ballarat"],
        "Queensland": ["Brisbane", "Gold Coast", "Sunshine Coast"],
        "Western Australia": ["Perth", "Fremantle", "Mandurah"],
        "South Australia": ["Adelaide", "Mount Gambier"],
        "Tasmania": ["Hobart", "Launceston"],
        "Australian Capital Territory": ["Canberra"]
    ], timeZones: ["Australia/Sydney", "Australia/Melbourne", "Australia/Brisbane", "Australia/Perth", "Australia/Adelaide", "Australia/Darwin"]),
    
    CountryData(name: "New Zealand", code: "NZ", states: [
        "Auckland": ["Auckland", "Manukau", "North Shore"],
        "Wellington": ["Wellington", "Lower Hutt", "Upper Hutt"],
        "Canterbury": ["Christchurch", "Timaru"],
        "Waikato": ["Hamilton", "Tauranga"],
        "Otago": ["Dunedin"]
    ], timeZones: ["Pacific/Auckland"]),
    
    // 中东
    CountryData(name: "Israel", code: "IL", states: [
        "Tel Aviv": ["Tel Aviv", "Jaffa"],
        "Jerusalem": ["Jerusalem"],
        "Haifa": ["Haifa"],
        "Rishon LeZion": ["Rishon LeZion"],
        "Petah Tikva": ["Petah Tikva"]
    ], timeZones: ["Asia/Jerusalem"]),
    
    CountryData(name: "Qatar", code: "QA", states: [
        "Doha": ["Doha"],
        "Al Rayyan": ["Al Rayyan"],
        "Umm Salal": ["Umm Salal"],
        "Al Wakrah": ["Al Wakrah"]
    ], timeZones: ["Asia/Qatar"])
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