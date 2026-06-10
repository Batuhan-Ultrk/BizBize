import Fluent
import Vapor

struct LeaderboardController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let protected = routes
            .grouped(UserToken.authenticator())
            .grouped("leaderboard")

        protected.get(use: index)
    }

    @Sendable
    func index(req: Request) async throws -> LeaderboardResponseDTO {
        let currentUser = try req.auth.require(User.self)
        let currentUserID = try currentUser.requireID()

        let allUsers = try await User.query(on: req.db).all()
        let allScores = try await UserScore.query(on: req.db).all()

        struct TempEntry {
            let user: User
            let weeklyPoints: Int
            let totalPoints: Int
        }

        var entries: [TempEntry] = []
        for user in allUsers {
            let score = allScores.first(where: { $0.$user.id == user.id })
            entries.append(TempEntry(
                user: user,
                weeklyPoints: score?.weeklyPoints ?? 0,
                totalPoints: score?.totalPoints ?? 0
            ))
        }

        entries.sort { a, b in
            if a.weeklyPoints != b.weeklyPoints {
                return a.weeklyPoints > b.weeklyPoints
            }
            if a.totalPoints != b.totalPoints {
                return a.totalPoints > b.totalPoints
            }
            return a.user.firstName < b.user.firstName
        }

        var leaderboardEntries: [LeaderboardEntryDTO] = []
        var myEntry: LeaderboardEntryDTO?

        for (index, entry) in entries.enumerated() {
            let rank = index + 1
            let dto = try LeaderboardEntryDTO(
                rank: rank,
                user: entry.user.toPublicDTO(),
                weeklyPoints: entry.weeklyPoints,
                totalPoints: entry.totalPoints
            )
            leaderboardEntries.append(dto)

            if entry.user.id == currentUserID {
                myEntry = dto
            }
        }

        let topTen = Array(leaderboardEntries.prefix(10))
        return LeaderboardResponseDTO(topTen: topTen, myEntry: myEntry)
    }
}
