import XCTest
import Combine

@testable import App

class GetLocationDetailsRepositoryTests: XCTestCase {

    var SUT: GetLocationDetailsRepositoryProtocol!
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
            XCTAssertEqual(url?.path, "/api/location/0")
        }

        SUT = GetLocationDetailsRepository(apiClient: analyzer)
        _ = SUT.getLocationDetails(for: 0)
    }

    func testSearchingLocations() {
        // Using default implementation as it already contains mechanism to mock data
        // It uses BuildConfiguration: Offline to load stubs from GetLocationDetails.json
        SUT = GetLocationDetailsRepository()

        SUT
            .getLocationDetails(for: 0)
            .expectSuccess(byStoringIn: &cancellables) { details in
                XCTAssertEqual(details.woeid, 44418)
                XCTAssertEqual(details.title, "London")
                XCTAssertEqual(details.consolidatedWeather.count, 6)
            }
            .wait(for: self)
    }

    func testSearchingLocationsFailure() {
        SUT = GetLocationDetailsRepository(apiClient: .inject(failureStub: URLError(.callIsActive)))

        SUT
            .getLocationDetails(for: 0)
            .expectFailure(byStoringIn: &cancellables) { responseError in
                XCTAssertTrue(responseError is URLError)
            }
            .wait(for: self)
    }
}
