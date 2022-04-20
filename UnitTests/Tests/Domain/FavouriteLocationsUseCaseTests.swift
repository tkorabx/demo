import XCTest
import Combine

@testable import App

class FavouriteLocationsUseCaseTests: XCTestCase {

    var SUT: FavouriteLocationsUseCaseProtocol!
    var repository: FavouriteLocationsRepositoryProtocol!
    var cancellables: Set<AnyCancellable>!

    let firstLocation = Location(woeid: 2, title: "title2", locationType: "type")
    let secondLocation = Location(woeid: 1, title: "title", locationType: "type")

    override func setUp() {
        super.setUp()
        cancellables = []
        repository = FavouriteLocationsRepository(userDefaults: .mocked(for: #file))
        SUT = FavouriteLocationsUseCase(repository: repository, waitDuration: 0)
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
        repository = nil
    }

    func testTogglingFavouriteLocation() {
        XCTAssertTrue(repository.favouriteLocations.isEmpty)

        SUT
            .toggleFavouriteLocation(location: firstLocation)
            .expectSuccess(byStoringIn: &cancellables) { _ in
                XCTAssertEqual(self.repository.favouriteLocations.count, 1)
            }
            .wait(for: self)

        SUT
            .toggleFavouriteLocation(location: secondLocation)
            .expectSuccess(byStoringIn: &cancellables) { _ in
                XCTAssertEqual(self.repository.favouriteLocations.count, 2)
                XCTAssertEqual(self.repository.favouriteLocations.first?.woeid, 1)
                XCTAssertEqual(self.SUT.favouriteLocations, self.repository.favouriteLocations)
            }
            .wait(for: self)
    }
}
