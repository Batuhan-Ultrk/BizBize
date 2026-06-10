import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

enum BadgeType: String, Codable, CaseIterable {
    case detective
    case socialButterfly = "social_butterfly"
    case teamPlayer = "team_player"
    case monthlySocial = "monthly_social"
}

final class Badge: Model, Content, @unchecked Sendable {
    static let schema = "badges"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "type")
    var type: String

    @Field(key: "earned_at")
    var earnedAt: Date

    @OptionalField(key: "period_label")
    var periodLabel: String?

    init() {}

    init(
        id: UUID? = nil,
        userID: User.IDValue,
        type: String,
        earnedAt: Date = Date(),
        periodLabel: String? = nil
    ) {
        self.id = id
        self.$user.id = userID
        self.type = type
        self.earnedAt = earnedAt
        self.periodLabel = periodLabel
    }
}
