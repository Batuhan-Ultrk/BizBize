import Fluent

struct CreateDailyChallengeCandidate: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("daily_challenge_candidates")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("daily_challenge_candidates").delete()
    }
}
