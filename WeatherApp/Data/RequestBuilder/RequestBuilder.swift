import Foundation

struct RequestBuilder {

    func build(request: Request) -> URLRequest {
        var components = URLComponents()

        components.scheme = Environment.urlScheme
        components.host = Environment.urlHost
        components.path = request.path
        components.queryItems = request.queryItems

        guard let url = components.url else {
            fatalError("Couldn't build URL from the input")
        }

        return URLRequest(url: url)
    }
}

extension RequestBuilder {

    enum Request {

        case searchLocations(query: String)
        case locationDetails(id: Int)

        fileprivate var path: String {
            switch self {
            case .searchLocations:
                return "/api/location/search"
            case .locationDetails(let id):
                return "/api/location/\(id)"
            }
        }

        fileprivate var queryItems: [URLQueryItem] {
            switch self {
            case .searchLocations(let query):
                return [URLQueryItem(name: "query", value: query)]
            case .locationDetails:
                return []
            }
        }
    }
}
