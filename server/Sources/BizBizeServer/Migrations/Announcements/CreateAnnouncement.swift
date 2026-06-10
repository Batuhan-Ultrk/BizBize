import Fluent

struct CreateAnnouncement: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let type = try await database.enum("announcement_type")
            .case("birthday")
            .case("gift")
            .case("event")
            .case("operational")
            .create()

        try await database.schema(Announcement.schema)
            .id()
            .field("created_by_user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("type", type, .required)
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("event_date", .datetime)
            .field("has_rsvp", .bool, .required)
            .field("target_user_ids", .array(of: .uuid), .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Announcement.schema).delete()
        try await database.enum("announcement_type").delete()
    }
}
