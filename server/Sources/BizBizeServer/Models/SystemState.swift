import Fluent
import Vapor

final class SystemState: Model, Content, @unchecked Sendable {
    static let schema = "system_states"

    @ID(custom: "key", generatedBy: .user)
    var id: String?

    @Field(key: "value")
    var value: String

    init() {}

    init(key: String, value: String) {
        self.id = key
        self.value = value
    }
}
