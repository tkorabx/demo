import Foundation
import Combine

final class ApiJsonDecoder: JSONDecoder {

    fileprivate static let shared = ApiJsonDecoder()

    private lazy var fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }()

    private lazy var basicDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
        dateDecodingStrategy = .custom { [unowned fullDateFormatter, unowned basicDateFormatter] decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let date = fullDateFormatter.date(from: dateString) ?? basicDateFormatter.date(from: dateString)

            guard let date = date else {
                throw DecodingError.typeMismatch(
                    Date.self,
                    .init(
                        codingPath: [],
                        debugDescription: "Couldn't decode date",
                        underlyingError: nil
                    )
                )
            }

            return date
        }
    }
}

// Creating formatters is quite heavy operation
// Decided to go with single instance hidden behind protocol extension
// This way I have only once instance of formatter and it's not exposed to public
extension TopLevelDecoder where Self == ApiJsonDecoder {

    static func apiDecoder() -> ApiJsonDecoder {
        .shared
    }
}
