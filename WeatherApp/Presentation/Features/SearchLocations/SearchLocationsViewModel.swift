import Foundation
import Combine

final class SearchLocationsViewModel: ObservableObject {

    enum ViewState {
        case success([Location])
        case noResults
        case failure
        case idle(favourite: [Location])
        case loading
    }

    @Published var viewState: ViewState
    @Published var searchText = ""

    private let uiQueue: DispatchQueue
    private let searchLocationsUseCase: SearchLocationsUseCaseProtocol
    private let favouriteUseCase: FavouriteLocationsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        searchLocationsUseCase: SearchLocationsUseCaseProtocol = SearchLocationsUseCase(),
        favouriteUseCase: FavouriteLocationsUseCaseProtocol = FavouriteLocationsUseCase(),
        uiQueue: DispatchQueue = .main
    ) {
        self.searchLocationsUseCase = searchLocationsUseCase
        self.favouriteUseCase = favouriteUseCase
        self.uiQueue = uiQueue
        self.viewState = .idle(favourite: favouriteUseCase.favouriteLocations)
        listenSearchTextChanges()
    }

    func shouldIndicateFavourite(location: Location) -> Bool {
        favouriteUseCase.isLocationFavourite(location.woeid)
    }

    func onAppear() {
        // Triggers update of favourite indication in list's rows
        switch viewState {
        case .idle:
            viewState = .idle(favourite: favouriteUseCase.favouriteLocations)
        case .success(let locations):
            viewState = .success(locations)
        default:
            break
        }
    }

    private func listenSearchTextChanges() {
        $searchText
            .removeDuplicates()
            .flatMap { value in
                self.searchLocationsUseCase
                    .trySearchingLocation(by: value) {
                        self.viewState = .loading
                    }
                    .map(ViewState.success)
                    .catch { error -> AnyPublisher<ViewState, Never>  in
                        let value = self.errorToViewState(error)
                        return Just(value).eraseToAnyPublisher()
                    }
            }
            .setFailureType(to: Never.self)
            .receive(on: uiQueue)
            .assign(to: \.viewState, on: self)
            .store(in: &cancellables)
    }

    private func errorToViewState(_ error: SearchLocationsError) -> ViewState {
        switch error {
        case .queryTooShort:
            return .idle(favourite: favouriteUseCase.favouriteLocations)
        case .noResults:
            return .noResults
        case .other:
            return .failure
        }
    }
}
