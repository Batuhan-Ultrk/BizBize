import Fluent

struct CreatePollVote: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PollVote.schema)
            .id()
            .field("poll_id", .uuid, .required, .references(Poll.schema, "id", onDelete: .cascade))
            .field("option_id", .uuid, .required, .references(PollOption.schema, "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "poll_id", "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PollVote.schema).delete()
    }
}
