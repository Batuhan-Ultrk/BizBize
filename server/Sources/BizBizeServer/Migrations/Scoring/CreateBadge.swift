import Fluent

struct CreateBadge: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("badges")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("type", .string, .required)
            .field("earned_at", .datetime, .required)
            .field("period_label", .string)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("badges").delete()
    }
}
