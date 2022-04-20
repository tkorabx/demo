import SwiftUI

struct LocationDetailsView: View {

    @StateObject var viewModel: LocationDetailsViewModel

    init(location: Location) {
        _viewModel = .init(wrappedValue: LocationDetailsViewModel(location: location))
    }

    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .success(let uiData):
                List {
                    header(uiData: uiData)
                    dayWeatherView(header: "location.details.today".localized, day: uiData.today, isToday: true)
                    ForEach(uiData.nextDays, id: \.date) {
                        dayWeatherView(header: $0.date, day: $0)
                    }
                }
                .navigationTitle(uiData.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.navigationBarButtonSelected) {
                            Image(systemName: uiData.isFavourite ? "star.fill" : "star")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            case .failure:
                List {
                    InfoView(content: .failure)
                }
            case .loading:
                List {
                    InfoView(content: .loading)
                }
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }

    private func header(uiData: LocationDetailsViewModel.UIData) -> some View {
        Section("location.details.general".localized) {
            // Mocked asset as I don't have mapping list from state to assets
            HStack {
                Spacer()
                Image(systemName: "cloud.sun.rain.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.accentColor, .yellow, Color.accentColor.opacity(0.5))
                    .font(.system(size: 100))
                Spacer()
            }
            .listRowSeparator(.hidden)
            ListRow(key: "location.details.name", value: uiData.name)
            ListRow(key: "location.details.type", value: uiData.type)
            ListRow(key: "location.details.timezone", value: uiData.timezone)
        }
    }

    private func dayWeatherView(header: String, day: LocationDetailsViewModel.UIData.DayUIData, isToday: Bool = false) -> some View {
        Section(header) {
            ListRow(key: isToday ? "location.details.currently" : "location.details.predicting", value: day.description, isAccented: true)
            if isToday {
                ListRow(key: "location.details.temperature", value: day.currentTemperature, isAccented: true)
            }
            ListRow(key: "location.details.min.temperature", value: day.minTemperature)
            ListRow(key: "location.details.max.temperature", value: day.maxTemperature)
            ListRow(key: "location.details.air.pressure", value: day.airPressure)
            ListRow(key: "location.details.wind.speed", value: day.windSpeed)
            ListRow(key: "location.details.humidity", value: day.humidity)
            ListRow(key: "location.details.visibility", value: day.visibility)
        }
    }
}
