import XCTest
import Combine

@testable import App

class SearchLocationsRepositoryTests: XCTestCase {

    var SUT: SearchLocationsRepositoryProtocol!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testRequest() {
        let analyzer = RequestAnalyzer { request in
            let url = request.url
            XCTAssertEqual(url?.scheme, "mock")
            XCTAssertEqual(url?.host, "www.metaweather.com")
            XCTAssertEqual(url?.path, "/api/location/search")
            XCTAssertEqual(url?.query, "query=123")
        }

        SUT = SearchLocationsRepository(apiClient: analyzer)
        _ = SUT.searchLocations(by: "123")
    }

    func testSearchingLocations() {
        // Using default implementation as it already contains mechanism to mock data
        // It uses BuildConfiguration: Offline to load stubs from SearchLocations.json
        SUT = SearchLocationsRepository()

        SUT
            .searchLocations(by: "")
            .expectSuccess(byStoringIn: &cancellables) { locations in
                XCTAssertEqual(locations.count, 11)
                XCTAssertEqual(locations.first?.title, "San Francisco")
                XCTAssertEqual(locations.last?.title, "Santa Fe")
                XCTAssertEqual(locations.last?.woeid, 2488867)
            }
            .wait(for: self)
    }

    func testSearchingLocationsFailure() {
        SUT = SearchLocationsRepository(apiClient: .inject(failureStub: URLError(.callIsActive)))

        SUT
            .searchLocations(by: "")
            .expectFailure(byStoringIn: &cancellables) { responseError in
                XCTAssertTrue(responseError is URLError)
            }
            .wait(for: self)
    }
}
