import SwiftUI

@main
struct AppLauncher {

    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            WeatherApp.main()
        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {

    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}

struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SearchLocationsView()
            }
        }
    }
}
