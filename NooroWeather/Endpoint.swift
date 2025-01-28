import Foundation

enum RequestMethod: String {
    case get = "GET"
}

protocol Endpoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var token: String { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var scheme: String {
        return "https"
    }

    var baseURL: String {
        "api.weatherapi.com"
    }

    var token: String {
        "aa57f7a69f9d4bbe82a201024252701"
    }

    func asURLRequest() throws -> URLRequest {

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host =  baseURL
        urlComponents.path = path
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }
}

enum WeatherEndpoint {
    case current(query: String)
    case search(query: String)
}

extension WeatherEndpoint: Endpoint {
    var method: RequestMethod {
        .get
    }
    
    var path: String {
        switch self {
        case .current:
            return "/v1/current.json"
        case .search:
            return "/v1/search.json"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "key", value: token)
        ]
        
        switch self {
        case .current(let query):
            queryItems.append(URLQueryItem(name: "aqi", value: "no"))
            queryItems.append(URLQueryItem(name: "q", value: query))
        case .search(let query):
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        
        return queryItems
    }
}
