import Fluent
import Vapor
import struct Foundation.UUID

enum HintType: String, Codable, CaseIterable {
    case seniority
    case department
    case habit
    case yesno
    case funFact
}

final class Hint: Model, Content, @unchecked Sendable {
    static let schema = "hints"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "type")
    var type: String

    @Field(key: "text")
    var text: String

    @Field(key: "reveal_order")
    var revealOrder: Int

    init() {}

    init(
        id: UUID? = nil,
        userID: User.IDValue,
        type: String,
        text: String,
        revealOrder: Int
    ) {
        self.id = id
        self.$user.id = userID
        self.type = type
        self.text = text
        self.revealOrder = revealOrder
    }
}
