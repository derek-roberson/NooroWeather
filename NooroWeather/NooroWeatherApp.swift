import SwiftUI

@main
struct NooroWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreen(viewModel: .init())
        }
    }
}
