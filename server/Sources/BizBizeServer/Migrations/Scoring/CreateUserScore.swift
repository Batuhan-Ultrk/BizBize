import Fluent

struct CreateUserScore: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user_scores")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("weekly_points", .int, .required)
            .field("total_points", .int, .required)
            .field("monthly_engagement_score", .int, .required)
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user_scores").delete()
    }
}
