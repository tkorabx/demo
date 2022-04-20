import Foundation

struct LocationDetails: Codable {

    let woeid: Int
    let consolidatedWeather: [ConsolidatedWeather]
    let sources: [Source]
    let title, locationType, timezone: String

    struct ConsolidatedWeather: Codable {
        let id: Int
        let weatherStateName: String
        let created, applicableDate: Date
        let minTemp, maxTemp, theTemp, windSpeed: Double
        let windDirection, airPressure: Double
        let humidity: Int
        let visibility: Double
    }

    struct Source: Codable {
        let title: String
    }
}
