import XCTest

@testable import App

class FavouriteLocationsRepositoryTests: XCTestCase {

    var userDefaults: UserDefaults!
    var SUT: FavouriteLocationsRepositoryProtocol!

    let firstLocation = Location(woeid: 2, title: "title2", locationType: "type")
    let secondLocation = Location(woeid: 1, title: "title", locationType: "type")

    override func setUp() {
        super.setUp()
        userDefaults = .mocked(for: #file)
        SUT = FavouriteLocationsRepository(userDefaults: userDefaults)
    }

    override func tearDown() {
        super.tearDown()
        userDefaults = nil
        SUT = nil
    }

    func testLikingLocations() {
        SUT.set(location: firstLocation, favourite: true)
        XCTAssertEqual(SUT.favouriteLocations.count, 1)

        SUT.set(location: secondLocation, favourite: true)
        XCTAssertEqual(SUT.favouriteLocations.count, 2)
        XCTAssertEqual(SUT.favouriteLocations.first?.woeid, 1)
    }

    func testDislikingLocations() {
        SUT.set(location: firstLocation, favourite: true)
        XCTAssertEqual(SUT.favouriteLocations.count, 1)

        SUT.set(location: firstLocation, favourite: false)
        XCTAssertTrue(SUT.favouriteLocations.isEmpty)
    }
}
