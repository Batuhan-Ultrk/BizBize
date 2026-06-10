import Fluent

struct CreatePoll: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let type = try await database.enum("poll_type")
            .case("manual")
            .case("dailyLunch")
            .create()

        try await database.schema(Poll.schema)
            .id()
            .field("created_by_user_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("type", type, .required)
            .field("question", .string, .required)
            .field("expires_at", .datetime)
            .field("target_user_ids", .array(of: .uuid), .required)
            .field("day_key", .string)
            .field("created_at", .datetime)
            .unique(on: "type", "day_key")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Poll.schema).delete()
        try await database.enum("poll_type").delete()
    }
}
