import Fluent

struct CreateDailyChallenge: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("daily_challenges")
            .id()
            .field("day_key", .string, .required)
            .field("selected_user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("candidate_user_ids", .array(of: .uuid), .required)
            .field("created_at", .datetime)
            .unique(on: "day_key")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("daily_challenges").delete()
    }
}
