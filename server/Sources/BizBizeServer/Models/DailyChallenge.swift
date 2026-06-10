import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class DailyChallenge: Model, Content, @unchecked Sendable {
    static let schema = "daily_challenges"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "day_key")
    var dayKey: String

    @Parent(key: "selected_user_id")
    var selectedUser: User

    @Field(key: "candidate_user_ids")
    var candidateUserIds: [UUID]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        dayKey: String,
        selectedUserID: User.IDValue,
        candidateUserIds: [UUID]
    ) {
        self.id = id
        self.dayKey = dayKey
        self.$selectedUser.id = selectedUserID
        self.candidateUserIds = candidateUserIds
    }
}
