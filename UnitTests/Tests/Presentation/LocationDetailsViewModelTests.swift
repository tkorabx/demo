import XCTest
import Combine

@testable import App

class LocationDetailsViewModelTests: XCTestCase {

    var SUT: LocationDetailsViewModel!
    var repository: FavouriteLocationsRepositoryProtocol!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        repository = FavouriteLocationsRepository(userDefaults: .mocked(for: #file))
        cancellables = []
        SUT = LocationDetailsViewModel(
            location: .init(woeid: 1, title: "", locationType: ""),
            detailsUseCase: GetLocationDetailsUseCase(),
            favouriteUseCase: FavouriteLocationsUseCase(repository: repository, waitDuration: 0.0),
            uiQueue: .init(label: #file)
        )
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
        repository = nil
    }

    func testLoadingDetails() {
        SUT.onAppear()

        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { output in
                switch output {
                case .success(let uiData):
                    XCTAssertEqual(uiData.name, "London")
                case .loading:
                    // Initial - Skipping
                    break
                case .failure:
                    XCTFail()
                }
            }
            .wait(for: self)
    }

    func testTogglingFavourite() {
        testLoadingDetails()

        XCTAssertTrue(repository.favouriteLocations.isEmpty)

        SUT.navigationBarButtonSelected()

        var isFirstCheck = true

        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { output in
                switch output {
                case .loading:
                    // Initial - Skipping
                    break
                case .success(let uiData):
                    if isFirstCheck {
                        isFirstCheck = false
                        XCTAssertFalse(uiData.isFavourite)
                    } else {
                        XCTAssertTrue(uiData.isFavourite)
                    }
                default:
                    XCTFail()
                }
            }
            .wait(for: self)
    }
}
