import Foundation
import Combine

final class ApiClient: ApiClientProtocol {
    
    let session: URLSession = .shared
    
    func dataTaskPublisher(from request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        session.dataTaskPublisher(for: request)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}
