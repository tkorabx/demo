import Foundation
import Combine

protocol FavouriteLocationsUseCaseProtocol {
    var favouriteLocations: [Location] { get }
    func isLocationFavourite(_ locationId: Int) -> Bool
    func toggleFavouriteLocation(location: Location) -> AnyPublisher<Bool, Never>
}

protocol FavouriteLocationsRepositoryProtocol {
    var favouriteLocations: [Location] { get }
    func set(location: Location, favourite: Bool)
}

final class FavouriteLocationsUseCase: FavouriteLocationsUseCaseProtocol {

    private let repository: FavouriteLocationsRepositoryProtocol
    private let waitDuration: Double

    var favouriteLocations: [Location] {
        repository.favouriteLocations
    }

    private var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>? {
        willSet {
            timerPublisher?.upstream.connect().cancel()
        }
    }

    init(
        repository: FavouriteLocationsRepositoryProtocol = FavouriteLocationsRepository(),
        waitDuration: Double = 0.25
    ) {
        self.repository = repository
        self.waitDuration = waitDuration
    }

    deinit {
        timerPublisher?.upstream.connect().cancel()
    }

    func isLocationFavourite(_ locationId: Int) -> Bool {
        repository
            .favouriteLocations
            .contains(where: { $0.woeid == locationId })
    }

    func toggleFavouriteLocation(location: Location) -> AnyPublisher<Bool, Never> {
        let timerPublisher = Timer
            .publish(every: waitDuration, on: .current, in: .common)
            .autoconnect()

        self.timerPublisher = timerPublisher

        return timerPublisher
            .map { [weak self] _ -> Bool in
                self?.timerPublisher?.upstream.connect().cancel()
                return self?.isLocationFavourite(location.woeid) ?? false
            }
            .map { [weak self] isFavourite in
                let newValue = !isFavourite
                self?.repository.set(location: location, favourite: newValue)
                return newValue
            }
            .eraseToAnyPublisher()
    }
}
