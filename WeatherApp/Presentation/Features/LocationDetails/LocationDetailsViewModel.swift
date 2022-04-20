import Foundation
import Combine

final class LocationDetailsViewModel: ObservableObject {

    enum ViewState {
        case loading
        case success(UIData)
        case failure
    }

    struct UIData {

        let name: String
        let type: String
        let timezone: String
        fileprivate(set) var isFavourite: Bool
        let today: DayUIData
        let nextDays: [DayUIData]

        struct DayUIData {
            let date: String
            let description: String
            let windSpeed: String
            let currentTemperature: String
            let minTemperature: String
            let maxTemperature: String
            let airPressure: String
            let humidity: String
            let visibility: String
        }
    }

    @Published var viewState: ViewState = .loading

    private let location: Location
    private let uiQueue: DispatchQueue
    private let favouriteUseCase: FavouriteLocationsUseCaseProtocol
    private let detailsUseCase: GetLocationDetailsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        location: Location,
        detailsUseCase: GetLocationDetailsUseCaseProtocol = GetLocationDetailsUseCase(),
        favouriteUseCase: FavouriteLocationsUseCaseProtocol = FavouriteLocationsUseCase(),
        uiQueue: DispatchQueue = .main
    ) {
        self.location = location
        self.uiQueue = uiQueue
        self.detailsUseCase = detailsUseCase
        self.favouriteUseCase = favouriteUseCase
    }

    func onAppear() {
        detailsUseCase
            .getLocationDetails(for: location.woeid)
            .tryMap(convertDetailsToUIData)
            .map(ViewState.success)
            .catch { _ -> AnyPublisher<ViewState, Never> in
                Just(.failure).eraseToAnyPublisher()
            }
            .receive(on: uiQueue)
            .assign(to: \.viewState, on: self)
            .store(in: &cancellables)
    }

    func navigationBarButtonSelected() {
        favouriteUseCase
            .toggleFavouriteLocation(location: location)
            .map { [weak self] isFavourite in
                switch self?.viewState {
                case .success(var uiData):
                    uiData.isFavourite = isFavourite
                    return .success(uiData)
                default:
                    return self?.viewState ?? .failure
                }
            }
            .assign(to: \.viewState, on: self)
            .store(in: &cancellables)
    }

    private func convertDetailsToUIData(_ details: LocationDetails) throws -> UIData {
        var days = details.consolidatedWeather
        let today = days.removeFirst()

        let dayMapper: (LocationDetails.ConsolidatedWeather) -> UIData.DayUIData = {
            .init(
                date: $0.applicableDate.text(using: .textualDateFormatter),
                description: $0.weatherStateName,
                windSpeed: String(format: "%.0f mph", $0.windSpeed),
                currentTemperature: String(format: "%.0f°C", $0.theTemp),
                minTemperature: String(format: "%.0f°C", $0.minTemp),
                maxTemperature: String(format: "%.0f°C", $0.maxTemp),
                airPressure: String(format: "%.0f mbar", $0.airPressure),
                humidity: String(format: "%.0f%%", $0.humidity),
                visibility: String(format: "%.2f miles", $0.visibility)
            )
        }

        return .init(
            name: details.title,
            type: details.locationType,
            timezone: details.timezone,
            isFavourite: favouriteUseCase.isLocationFavourite(location.woeid),
            today: dayMapper(today),
            nextDays: days.map(dayMapper)
        )
    }
}

private extension Date {

    func text(using formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
}

private extension DateFormatter {

    static let textualDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
}
