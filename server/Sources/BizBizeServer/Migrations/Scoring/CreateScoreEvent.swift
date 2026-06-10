import Fluent

struct CreateScoreEvent: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("score_events")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("points", .int, .required)
            .field("type", .string, .required)
            .field("source_id", .uuid)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("score_events").delete()
    }
}
