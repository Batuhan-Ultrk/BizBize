import Fluent
import struct Foundation.UUID

//struct MakeUserTokenUserIDUnique: AsyncMigration {
//    func prepare(on database: any Database) async throws {
//        let tokens = try await UserToken.query(on: database)
//            .sort(\.$createdAt, .descending)
//            .all()
//        var seenUserIds = Set<UUID>()
//
//        for token in tokens {
//            let userID = token.$user.id
//            if seenUserIds.contains(userID) {
//                try await token.delete(on: database)
//            } else {
//                seenUserIds.insert(userID)
//            }
//        }
//
//        try await database.schema(UserToken.schema)
//            .unique(on: "user_id")
//            .update()
//    }
//
//    func revert(on database: any Database) async throws {
//        try await database.schema(UserToken.schema)
//            .deleteUnique(on: "user_id")
//            .update()
//    }
//}
