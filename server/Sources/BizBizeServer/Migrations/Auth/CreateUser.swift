import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("birth_date", .datetime, .required)
            .field("phone_number", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("department", .string)
            .field("start_date", .datetime)
            .field("profile_photo", .string)
            .field("password_reset_required", .bool, .required)
            .field("created_at", .datetime)
            .unique(on: "email")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
