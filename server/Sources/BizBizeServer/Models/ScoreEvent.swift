import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class ScoreEvent: Model, Content, @unchecked Sendable {
    static let schema = "score_events"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "points")
    var points: Int

    @Field(key: "type")
    var type: String

    @OptionalField(key: "source_id")
    var sourceId: UUID?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userID: User.IDValue,
        points: Int,
        type: String,
        sourceId: UUID? = nil
    ) {
        self.id = id
        self.$user.id = userID
        self.points = points
        self.type = type
        self.sourceId = sourceId
    }
}
