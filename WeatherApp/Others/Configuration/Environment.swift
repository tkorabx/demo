import Foundation

enum Environment {

    static var urlScheme: String {
        configurationProperties["APPLICATION_URL_SCHEME"] as? String ?? ""
    }

    static var urlHost: String {
        configurationProperties["APPLICATION_URL_HOST"] as? String ?? ""
    }

    static var isOffline: Bool {
        urlScheme == "mock"
    }

    private static let configurationProperties = Bundle.main.infoDictionary ?? [:]
}
