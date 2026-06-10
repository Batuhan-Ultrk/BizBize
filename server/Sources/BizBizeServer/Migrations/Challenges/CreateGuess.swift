import Fluent

struct CreateGuess: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("guesses")
            .id()
            .field("challenge_id", .uuid, .required, .references("daily_challenges", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("guessed_user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("is_correct", .bool, .required)
            .field("is_first_correct", .bool, .required)
            .field("timestamp", .datetime, .required)
            .unique(on: "challenge_id", "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("guesses").delete()
    }
}
