import SwiftUI

struct SearchLocationsView: View {

    @StateObject var viewModel = SearchLocationsViewModel()

    var body: some View {
        List {
            switch viewModel.viewState {
            case .success(let locations):
                ForEach(locations, id: \.woeid, content: row)
            case .failure:
                InfoView(content: .failure)
            case .noResults:
                InfoView(content: .empty)
            case .idle(let favouriteLocations):
                InfoView(content: .idle)
                if !favouriteLocations.isEmpty {
                    Section("search.locations.favourites".localized) {
                        ForEach(favouriteLocations, id: \.woeid, content: row)
                    }
                }
            case .loading:
                InfoView(content: .loading)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("search.locations.navigation.title")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.onAppear)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "search.locations.prompt"
        )
    }

    private func row(location: Location) -> some View {
        NavigationLink(destination: LocationDetailsView(location: location)) {
            HStack {
                Text(location.title)
                    .avenirNextFont(.bold, size: 17)
                    .foregroundColor(.textColor)
                if viewModel.shouldIndicateFavourite(location: location) {
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct SearchLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchLocationsView()
        }
    }
}
