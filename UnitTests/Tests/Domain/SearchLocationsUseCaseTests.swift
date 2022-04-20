import XCTest
import Combine

@testable import App

class SearchLocationsUseCaseTests: XCTestCase {

    var SUT: SearchLocationsUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        // Using default implementation as it already contains mechanism to mock data
        // It uses BuildConfiguration: Offline to load stubs from SearchLocations.json
        SUT = SearchLocationsUseCase(waitDuration: 0)
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testSearchingLocations() {
        SUT
            .trySearchingLocation(by: "123")
            .expectSuccess(byStoringIn: &cancellables) { locations in
                XCTAssertEqual(locations.count, 11)
                XCTAssertEqual(locations.first?.title, "San Francisco")
                XCTAssertEqual(locations.last?.title, "Santa Fe")
                XCTAssertEqual(locations.last?.woeid, 2488867)
            }
            .wait(for: self)
    }

    func testSearchingLocationsWithEmptySearchText() {
        SUT
            .trySearchingLocation(by: "")
            .expectFailure(byStoringIn: &cancellables) { error in
                guard case SearchLocationsError.queryTooShort = error else {
                    XCTFail()
                    return
                }
            }
            .wait(for: self)
    }

    func testSearchingLocationsWithTooShortSearchText() {
        SUT
            .trySearchingLocation(by: "1")
            .expectFailure(byStoringIn: &cancellables) { error in
                guard case SearchLocationsError.queryTooShort = error else {
                    XCTFail()
                    return
                }
            }
            .wait(for: self)
    }

    func testSearchingLocationsWithEmptyResponse() {
        let repository = SearchLocationsRepository(apiClient: .inject(successStub: "EmptyArray"))

        SUT = SearchLocationsUseCase(repository: repository, waitDuration: 0)

        SUT
            .trySearchingLocation(by: "123")
            .expectFailure(byStoringIn: &cancellables) { error in
                guard case SearchLocationsError.noResults = error else {
                    XCTFail()
                    return
                }
            }
            .wait(for: self)
    }

    func testSearchingLocationsWithFailure() {
        let repository = SearchLocationsRepository(apiClient: .inject(failureStub: URLError(.callIsActive)))

        SUT = SearchLocationsUseCase(repository: repository, waitDuration: 0)

        SUT
            .trySearchingLocation(by: "123")
            .expectFailure(byStoringIn: &cancellables) { error in
                guard case SearchLocationsError.other(let innerError) = error else {
                    XCTFail()
                    return
                }

                XCTAssertTrue(innerError is URLError)
            }
            .wait(for: self)
    }
}

