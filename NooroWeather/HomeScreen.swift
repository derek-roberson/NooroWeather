import Combine
import SwiftUI

@Observable
class HomeViewModel {
    struct State: Equatable {
        var searchText = ""
        var selectedCity: City?
        var searchedCities: [City] = []
        var error: WeatherClientError?
    }

    var state: State
    var isShowingAlert: Bool = false
    
    @ObservationIgnored
    private let client: WeatherClientType
    @ObservationIgnored
    private let repository: CityRepositoryType

    init(
        client: WeatherClientType = WeatherClient(),
        repository: CityRepositoryType = CityRepository()
    ) {
        self.client = client
        self.repository = repository
        var state: State = .init()
        state.selectedCity = try? repository.getSelectedCity()
        self.state = state
    }

    func search(query: String) async throws {
        do {
            state.searchedCities = try await client.getWeather(query: query)
        } catch let error as WeatherClientError {
            state.error = error
            isShowingAlert = true
        }
    }

    func select(city: City) async throws {
        state.selectedCity = city
        state.searchText = ""
        state.searchedCities = []
        try await repository.add(city)
    }

    func clear() {
        state.searchedCities = []
        state.error = nil
        isShowingAlert = false
    }
}

struct HomeScreen: View {
    @State private var viewModel: HomeViewModel
    @State private var selectedCity: City?
    @State private var searchTask: Task<Void, Error>?
    @State private var isShowingAlert: Bool = false
    @FocusState var isSearching: Bool
    private let searchTextPublisher = PassthroughSubject<String, Never>()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            SearchBarView(
                text: $viewModel.state.searchText, isFocused: $isSearching,
                onClear: { viewModel.clear() }
            )
            .padding(.horizontal)
            .frame(height: 70)
            .onChange(of: viewModel.state.searchText) { _, newValue in
                searchTextPublisher.send(newValue)
            }
            .onReceive(
                searchTextPublisher
                    .debounce(
                        for: .milliseconds(500),
                        scheduler: RunLoop.main
                    )
            ) { debouncedSearchText in
                searchTask?.cancel()
                guard !debouncedSearchText.isEmpty else { return }

                searchTask = Task {
                    try await viewModel.search(
                        query: debouncedSearchText
                    )
                }
            }
            ZStack {
                VStack(spacing: 40) {
                    if isSearching || !viewModel.state.searchedCities.isEmpty {
                        List(
                            viewModel.state.searchedCities,
                            selection: $selectedCity
                        ) { city in
                            CityView(city: city)
                                .tag(city)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.inset)
                        .contentMargins(.top, 0, for: .scrollContent)
                        .background(Color.primary)
                        .onChange(of: selectedCity) { _, newValue in
                            isSearching = false
                            if let newValue {
                                Task {
                                    try await viewModel.select(city: newValue)
                                }
                            }
                        }
                    } else {
                        if let selectedCity = viewModel.selectedCity {
                            Spacer()
                                .frame(height: 40)

                            AsyncImage(
                                url: selectedCity.current.condition.iconUrl
                            ) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 123, height: 113)

                            Text(selectedCity.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            HStack(alignment: .top) {
                                Text(selectedCity.feelsLike)
                                    .font(.system(size: 75, weight: .bold))
                                Text("°")
                                    .font(.system(size: 30))
                            }

                            HStack(alignment: .center, spacing: 60) {
                                VStack(alignment: .center) {
                                    Text("Humidity")
                                        .font(.caption)
                                        .foregroundStyle(
                                            Color.secondary.opacity(0.5))
                                    Text(selectedCity.humidity + "%")
                                        .foregroundStyle(Color.secondary)
                                }
                                VStack(alignment: .center) {
                                    Text("UV")
                                        .font(.caption)
                                        .foregroundStyle(
                                            Color.secondary.opacity(0.5))
                                    Text(selectedCity.uv)
                                        .foregroundStyle(Color.secondary)
                                }
                                VStack(alignment: .center) {
                                    Text("Feels Like")
                                        .font(.caption)
                                        .foregroundStyle(
                                            Color.secondary.opacity(0.5))
                                    Text(selectedCity.feelsLike + "°")
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.3))
                            .cornerRadius(15)

                        } else {
                            Spacer()
                            VStack {
                                Text("No City Selected")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Spacer()
                                    .frame(height: 24)
                                Text("Please Search For A City")
                                    .font(.headline)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .alert(
            "Error", isPresented: $viewModel.isShowingAlert,
            presenting: viewModel.state.error
        ) { _ in
            Button("OK") {
                viewModel.clear()
            }
        } message: { error in
            Text(error.error.message)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if viewModel.state.selectedCity == nil {
                    isSearching = true
                }
            }
        }

    }
}

#Preview {
    HomeScreen(
        viewModel: .init(client: MockWeatherClient(
            weatherResponse: { _ in
                throw WeatherClientError(
                    error: WeatherError(
                        code: 1006,
                        message: "Bad API Key"
                    )
                )
            }
        )))
}

extension City {
    var name: String {
        location.name
    }

    var temp: String {
        String(Int(current.tempF))
    }
    var feelsLike: String {
        String(Int(current.feelslikeF))
    }

    var humidity: String {
        String(current.humidity)
    }

    var uv: String {
        String(current.uv)
    }

    static var test: (String) async throws -> [City] {
        { _ in
            [
                City(
                    location: .init(
                        name: "Testerazo"
                    ),
                    current: .init(
                        tempC: 13.6,
                        tempF: 56.4,
                        condition: .init(icon: ""),
                        humidity: 68,
                        feelslikeC: 13.6,
                        feelslikeF: 56.4,
                        uv: 1.5
                    )
                ),
                City(
                    location: .init(
                        name: "Testorf-Steinfort"
                    ),
                    current: .init(
                        tempC: 7.4,
                        tempF: 45.3,
                        condition: .init(icon: ""),
                        humidity: 87,
                        feelslikeC: 5.3,
                        feelslikeF: 41.5,
                        uv: 0.0
                    )
                ),
                City(
                    location: .init(
                        name: "Testico"
                    ),
                    current: .init(
                        tempC: 12.4,
                        tempF: 54.3,
                        condition: .init(icon: ""),
                        humidity: 26,
                        feelslikeC: 9.7,
                        feelslikeF: 49.4,
                        uv: 0.0
                    )
                ),
            ]
        }
    }
}

extension HomeViewModel {
    var selectedCity: City? {
        state.selectedCity
    }
}
