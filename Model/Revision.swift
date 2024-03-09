import Foundation
import SwiftData

@Model
class Revision {
    var user: String
    var timestamp: Date
    var size: Int
    var comment: String
    var seen: Bool

    init(user: String, timestamp: Date, size: Int, comment: String) {
        self.user = user
        self.timestamp = timestamp
        self.size = size
        self.comment = comment
        self.seen = false
    }

    func sameAs(other: Revision) -> Bool {
        return self.user == other.user && self.timestamp == other.timestamp
    }
}
