import XCTest
import Combine

@testable import App

class SearchLocationsViewModelTests: XCTestCase {

    var SUT: SearchLocationsViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        let favouritesRepository = FavouriteLocationsRepository(userDefaults: .mocked(for: #file))

        cancellables = []
        SUT = SearchLocationsViewModel(
            searchLocationsUseCase: SearchLocationsUseCase(waitDuration: 0),
            favouriteUseCase: FavouriteLocationsUseCase(repository: favouritesRepository, waitDuration: 0),
            uiQueue: .init(label: #file)
        )
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testInitialViewState() {
        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { output in
                switch output {
                case .idle(let favourites):
                    XCTAssertTrue(favourites.isEmpty)
                default:
                    XCTFail()
                }
            }
            .wait(for: self)
    }

    func testGeneratingViewState() {
        SUT.searchText = "123"

        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { output in
                switch output {
                case .success(let locations):
                    XCTAssertEqual(locations.count, 11)
                case .idle:
                    // Initial viewState - Skipping
                    break
                default:
                    XCTFail()
                }
            }
            .wait(for: self)
    }

    func testRefreshingFavouritesWhenIdle() {
        SUT.onAppear()

        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { output in
                switch output {
                case .idle(let favourites):
                    XCTAssertTrue(favourites.isEmpty)
                default:
                    XCTFail()
                }
            }
            .wait(for: self)
    }
}
