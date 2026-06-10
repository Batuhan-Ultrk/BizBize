import Fluent
import Vapor
import struct Foundation.UUID

final class DailyChallengeCandidate: Model, Content, @unchecked Sendable {
    static let schema = "daily_challenge_candidates"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil, userID: User.IDValue) {
        self.id = id
        self.$user.id = userID
    }
}
