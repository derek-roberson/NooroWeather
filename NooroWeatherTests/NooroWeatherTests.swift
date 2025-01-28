//
//  NooroWeatherTests.swift
//  NooroWeatherTests
//
//  Created by Derek on 1/28/25.
//

@testable import NooroWeather
import Testing

struct NooroWeatherTests {

    @Test func homeViewModelLoadsWithSavedValue() async throws {
        let mockCity = makeCity()
        let repository = MockCityRepository()
        try await repository.add(mockCity)
        let client = MockWeatherClient(weatherResponse: { _ in []} )
        let homeViewModel = HomeViewModel(client: client, repository: repository)
        #expect(homeViewModel.state.selectedCity == mockCity)
    }

    private func makeCity() -> City {
        .init(
            location: .init(
                name: "Atlanta"
            ),
            current: .init(
                tempC: 17.9,
                tempF: 71.2,
                condition: .init(icon: "//example.com"),
                humidity: 12,
                feelslikeC: 17.9,
                feelslikeF: 71.2,
                uv: 1.1)
        )
    }
}
