import Foundation
import Combine

enum SearchLocationsError: Error {
    case queryTooShort
    case noResults
    case other(Error)
}

protocol SearchLocationsUseCaseProtocol {
    func trySearchingLocation(by name: String, _ loadingTriggerSideEffect: (() -> Void)?) -> AnyPublisher<[Location], SearchLocationsError>
}

protocol SearchLocationsRepositoryProtocol {
    func searchLocations(by name: String) -> AnyPublisher<[Location], Error>
}

final class SearchLocationsUseCase: SearchLocationsUseCaseProtocol {

    private let repository: SearchLocationsRepositoryProtocol
    private let waitDuration: Double

    private var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>? {
        willSet {
            timerPublisher?.upstream.connect().cancel()
        }
    }

    init(
        repository: SearchLocationsRepositoryProtocol = SearchLocationsRepository(),
        waitDuration: Double = 1.5
    ) {
        self.repository = repository
        self.waitDuration = waitDuration
    }

    deinit {
        timerPublisher?.upstream.connect().cancel()
    }

    func trySearchingLocation(by name: String, _ loadingTriggerSideEffect: (() -> Void)? = nil) -> AnyPublisher<[Location], SearchLocationsError> {
        if name.isEmpty {
            timerPublisher = nil
            return Fail(error: SearchLocationsError.queryTooShort).eraseToAnyPublisher()
        }

        let timerPublisher = Timer
            .publish(every: waitDuration, on: .current, in: .common)
            .autoconnect()

        self.timerPublisher = timerPublisher

        return timerPublisher
            .tryMap { _ -> String in
                if name.count > 2 {
                    return name
                } else {
                    throw SearchLocationsError.queryTooShort
                }
            }
            .flatMap { [weak self] _ -> AnyPublisher<[Location], Error> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }

                loadingTriggerSideEffect?()
                self.timerPublisher?.upstream.connect().cancel()
                return self.repository.searchLocations(by: name)
            }
            .tryMap { searchedLocations in
                if searchedLocations.isEmpty {
                    throw SearchLocationsError.noResults
                } else {
                    return searchedLocations
                }
            }
            .mapError { error in
                switch error {
                case let error as SearchLocationsError:
                    return error
                default:
                    return SearchLocationsError.other(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
