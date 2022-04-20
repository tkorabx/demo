import Foundation
import Combine

final class GetLocationDetailsRepository: GetLocationDetailsRepositoryProtocol, GetLocationDetailsUseCaseProtocol {

    private let apiClient: ApiClientProtocol

    init(apiClient: ApiClientProtocol = .inject(successStub: "GetLocationDetails")) {
        self.apiClient = apiClient
    }

    func getLocationDetails(for id: Int) -> AnyPublisher<LocationDetails, Error> {
        let urlRequest = RequestBuilder().build(request: .locationDetails(id: id))
        return apiClient.execute(request: urlRequest)
    }
}
