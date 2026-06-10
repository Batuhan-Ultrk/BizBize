import Fluent

struct CreateAnnouncementRSVP: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let status = try await database.enum("announcement_rsvp_status")
            .case("attending")
            .case("notAttending")
            .create()

        try await database.schema(AnnouncementRSVP.schema)
            .id()
            .field("announcement_id", .uuid, .required, .references(Announcement.schema, "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("status", status, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "announcement_id", "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(AnnouncementRSVP.schema).delete()
        try await database.enum("announcement_rsvp_status").delete()
    }
}
