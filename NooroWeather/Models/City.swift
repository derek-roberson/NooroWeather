import Foundation

// MARK: - City
struct City: Codable, Hashable, Identifiable {
    let id = UUID()
    let location: Location
    let current: Current
    
    enum CodingKeys: String, CodingKey {
        case location
        case current
    }
    
}

// MARK: - Current
struct Current: Codable, Hashable {
    let tempC: Double
    let tempF: Double
    let condition: Condition
    let humidity: Int
    let feelslikeC, feelslikeF: Double
    let uv: Double

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case condition, humidity
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
        case uv
    }
}

// MARK: - Condition
struct Condition: Codable, Hashable {
    private let icon: String
    
    init(icon: String) {
        self.icon = icon
    }
    
    var iconUrl: URL? {
        let urlString = "https://" + String(icon.dropFirst(2))
        return URL(string: urlString)
    }
}

// MARK: - Location
struct Location: Codable, Hashable {
    let name: String
}
