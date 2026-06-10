import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

enum PollType: String, Codable, CaseIterable {
    case manual
    case dailyLunch
}

final class Poll: Model, Content, @unchecked Sendable {
    static let schema = "polls"

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: "created_by_user_id")
    var createdByUser: User?

    @Enum(key: "type")
    var type: PollType

    @Field(key: "question")
    var question: String

    @OptionalField(key: "expires_at")
    var expiresAt: Date?

    @Field(key: "target_user_ids")
    var targetUserIds: [UUID]

    @OptionalField(key: "day_key")
    var dayKey: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        createdByUserID: User.IDValue?,
        type: PollType,
        question: String,
        expiresAt: Date? = nil,
        targetUserIds: [UUID] = [],
        dayKey: String? = nil
    ) {
        self.id = id
        self.$createdByUser.id = createdByUserID
        self.type = type
        self.question = question
        self.expiresAt = expiresAt
        self.targetUserIds = targetUserIds
        self.dayKey = dayKey
    }
}
