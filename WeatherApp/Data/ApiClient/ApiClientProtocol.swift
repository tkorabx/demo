import Foundation
import Combine

protocol ApiClientProtocol {
    func execute<Success: Decodable>(request: URLRequest) -> AnyPublisher<Success, Error>
    func dataTaskPublisher(from request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error>
}

extension ApiClientProtocol {

    func execute<Success: Decodable>(request: URLRequest) -> AnyPublisher<Success, Error> {
        return dataTaskPublisher(from: request)
            .catch { error in
                Fail(error: error)
            }
            .map { (data: Data, response: URLResponse) in
                data
            }
            .decode(type: Success.self, decoder: .apiDecoder())
            .eraseToAnyPublisher()
    }
}

extension ApiClientProtocol where Self == ApiClient {

    static func inject(successStub: String) -> ApiClientProtocol {
        Environment.isOffline ? ApiClientStub(file: successStub) : ApiClient()
    }

    static func inject(failureStub: Error) -> ApiClientProtocol {
        Environment.isOffline ? ApiClientStub(error: failureStub) : ApiClient()
    }
}
