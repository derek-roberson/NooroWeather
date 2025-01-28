import Foundation

protocol CityRepositoryType {
    /// Inserts a new user in the data store.
    func add(_ city: City) async throws
    func getSelectedCity() throws -> City?
}

class MockCityRepository: CityRepositoryType {
    var selectedCity: City?
    
    func add(_ city: City) async throws {
        selectedCity = city
    }
    
    func getSelectedCity() throws -> City? {
        selectedCity
    }
}

struct CityRepository: CityRepositoryType {
    private var userDefaults: UserDefaults = .standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func add(_ city: City) async throws {
        let data = try encoder.encode(city)
        userDefaults.set(data, forKey: .repoistoryKey)
    }
    
    func getSelectedCity() throws -> City? {
        let data = userDefaults.data(forKey: .repoistoryKey)
        guard let data else  { return nil }
        let city = try decoder.decode(City.self, from: data)
        return city
    }
}

private extension String {
    static let repoistoryKey = "selectedCity"
}
