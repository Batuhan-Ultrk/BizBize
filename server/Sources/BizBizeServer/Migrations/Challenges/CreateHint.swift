import Fluent

struct CreateHint: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("hints")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("type", .string, .required)
            .field("text", .string, .required)
            .field("reveal_order", .int, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("hints").delete()
    }
}
