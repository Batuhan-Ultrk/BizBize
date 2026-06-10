import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class UserToken: Model, Content, @unchecked Sendable {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }

    static func generate(for user: User) throws -> UserToken {
        let random = [UInt8].random(count: 32).base64
        return try UserToken(value: random, userID: user.requireID())
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<UserToken, FieldProperty<UserToken, String>> {
        \UserToken.$value
    }

    static var userKey: KeyPath<UserToken, Parent<User>> {
        \UserToken.$user
    }

    var isValid: Bool {
        true
    }
}
