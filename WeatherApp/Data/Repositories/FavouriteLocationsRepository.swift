import Foundation
import Combine

final class FavouriteLocationsRepository: FavouriteLocationsRepositoryProtocol {

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    private let userDefaults: UserDefaults

    var favouriteLocations: [Location] {
        if let data = userDefaults.data(forKey: .kFavouriteCities),
           let stored = try? Self.decoder.decode([Location].self, from: data) {
            return stored
        }

        return []
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func set(location: Location, favourite: Bool) {
        var stored = favouriteLocations

        if favourite && !stored.contains(location) {
            stored.append(location)
        } else if !favourite && stored.contains(location) {
            stored.removeAll(where: { $0 == location })
        } else {
            return
        }

        stored.sort(by: { $0.title < $1.title })

        do {
            let data = try Self.encoder.encode(stored)
            userDefaults.set(data, forKey: .kFavouriteCities)
        } catch {
            assertionFailure("Couldn't store Data from [Location] instance")
        }
    }
}

private extension String {
    static let kFavouriteCities = "favourite_cities"
}
