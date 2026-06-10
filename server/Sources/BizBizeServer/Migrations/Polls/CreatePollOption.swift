import Fluent

struct CreatePollOption: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PollOption.schema)
            .id()
            .field("poll_id", .uuid, .required, .references(Poll.schema, "id", onDelete: .cascade))
            .field("text", .string, .required)
            .field("key", .string)
            .field("display_order", .int, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PollOption.schema).delete()
    }
}
