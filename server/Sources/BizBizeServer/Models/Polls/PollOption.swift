import Fluent
import Vapor
import struct Foundation.UUID

final class PollOption: Model, Content, @unchecked Sendable {
    static let schema = "poll_options"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "poll_id")
    var poll: Poll

    @Field(key: "text")
    var text: String

    @OptionalField(key: "key")
    var key: String?

    @Field(key: "display_order")
    var displayOrder: Int

    init() {}

    init(
        id: UUID? = nil,
        pollID: Poll.IDValue,
        text: String,
        key: String? = nil,
        displayOrder: Int
    ) {
        self.id = id
        self.$poll.id = pollID
        self.text = text
        self.key = key
        self.displayOrder = displayOrder
    }
}
