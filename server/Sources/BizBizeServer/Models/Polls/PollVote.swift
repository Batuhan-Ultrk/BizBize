import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class PollVote: Model, Content, @unchecked Sendable {
    static let schema = "poll_votes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "poll_id")
    var poll: Poll

    @Parent(key: "option_id")
    var option: PollOption

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        pollID: Poll.IDValue,
        optionID: PollOption.IDValue,
        userID: User.IDValue
    ) {
        self.id = id
        self.$poll.id = pollID
        self.$option.id = optionID
        self.$user.id = userID
    }
}
