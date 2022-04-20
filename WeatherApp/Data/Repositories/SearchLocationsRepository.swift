import Foundation
import Combine

final class SearchLocationsRepository: SearchLocationsRepositoryProtocol {

    private let apiClient: ApiClientProtocol

    init(apiClient: ApiClientProtocol = .inject(successStub: "SearchLocations")) {
        self.apiClient = apiClient
    }

    func searchLocations(by query: String) -> AnyPublisher<[Location], Error> {
        let urlRequest = RequestBuilder().build(request: .searchLocations(query: query))
        return apiClient.execute(request: urlRequest)
    }
}
