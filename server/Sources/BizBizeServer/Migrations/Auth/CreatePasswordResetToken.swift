import Fluent

struct CreatePasswordResetToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PasswordResetToken.schema)
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("expires_at", .datetime, .required)
            .field("created_at", .datetime)
            .unique(on: "value")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PasswordResetToken.schema).delete()
    }
}
