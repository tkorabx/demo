import Foundation

struct Location: Codable, Equatable {

    let woeid: Int
    let title: String
    let locationType: String

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.woeid == rhs.woeid
    }
}
