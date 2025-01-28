import Foundation

protocol WeatherClientType {
    func getWeather(query: String) async throws -> [City]
}

struct MockWeatherClient: WeatherClientType {
    var weatherResponse: (String) async throws -> [City]
    
    func getWeather(query: String) async throws -> [City] {
        try await weatherResponse(query)
    }
}

struct WeatherClient: WeatherClientType {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: config)
        self.session = session
    }

    func getWeather(query: String) async throws -> [City] {
        let search = WeatherEndpoint.search(query: query)
        do {
            let (searchData, searchUrlResponse) = try await session.data(
                for: search.asURLRequest())
            
            let locations: [Location] = try manageResponse(data: searchData, response: searchUrlResponse)
            
            let cities = try await withThrowingTaskGroup(of: (City.self)) { group in
                for location in locations {
                    group.addTask {
                        let currentWeather = WeatherEndpoint.current(
                            query: location.name
                        )
                        let (cityData, cityResponse) = try await session.data(
                            for: currentWeather.asURLRequest()
                        )
                        let city: City = try manageResponse(data: cityData, response: cityResponse)
                        return city
                    }
                }
                
                var _cities: [City] = []
                
                for try await city in group {
                    _cities.append(city)
                }
                
                return _cities
            }
            
            return cities
        } catch let error {
            throw WeatherClientError(
                error: WeatherError(
                    code: 0,
                    message: error.localizedDescription
                )
            )
        }
    }
    
    private func manageResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
            guard let response = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            switch response.statusCode {
            case 200...299:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw WeatherClientError(
                        error: WeatherError(
                            code: response.statusCode,
                            message: "Error decoding data"
                        )
                    )
                }
                
            default:
                guard let decodedError = try? JSONDecoder().decode(WeatherClientError.self, from: data) else {
                    throw WeatherClientError(error: WeatherError(
                        code: response.statusCode,
                        message: response.description
                    ))
                }
                throw decodedError
            }
        }
}

// MARK: - WeatherClientError
struct WeatherClientError: Codable, Identifiable, Equatable, Error {
    let error: WeatherError
    var id: String { String(error.code) }

    enum CodingKeys: String, CodingKey {
        case error = "error"
    }
}

// MARK: - Error
struct WeatherError: Codable, Equatable {
    let code: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
    }
}
