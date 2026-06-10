import Fluent

struct CreateSystemState: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("system_states")
            .field("key", .string, .identifier(auto: false))
            .field("value", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("system_states").delete()
    }
}
