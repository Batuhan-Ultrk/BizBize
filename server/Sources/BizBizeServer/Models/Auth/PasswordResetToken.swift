import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class PasswordResetToken: Model, Content, @unchecked Sendable {
    static let schema = "password_reset_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    @Field(key: "expires_at")
    var expiresAt: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, value: String, userID: User.IDValue, expiresAt: Date) {
        self.id = id
        self.value = value
        self.$user.id = userID
        self.expiresAt = expiresAt
    }

    static func generate(for user: User) throws -> PasswordResetToken {
        try PasswordResetToken(
            value: [UInt8].random(count: 32).base64,
            userID: user.requireID(),
            expiresAt: Date().addingTimeInterval(10 * 60)
        )
    }
}
