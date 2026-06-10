import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct ScoreController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let protected = routes
            .grouped(UserToken.authenticator())
            .grouped("scores")

        protected.get(":userID", use: show)
    }

    @Sendable
    func show(req: Request) async throws -> UserScoreDetailsResponseDTO {
        let _ = try req.auth.require(User.self)
        
        guard
            let userID = req.parameters.get("userID", as: UUID.self),
            let _ = try await User.find(userID, on: req.db)
        else {
            throw Abort(.notFound, reason: "Kullanıcı bulunamadı.")
        }

        let score = try await UserScore.query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()

        let events = try await ScoreEvent.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$createdAt, .descending)
            .all()
            .map { event in
                ScoreEventDetailDTO(
                    source: event.type,
                    points: event.points,
                    date: event.createdAt ?? Date()
                )
            }

        return UserScoreDetailsResponseDTO(
            totalScore: score?.totalPoints ?? 0,
            events: events
        )
    }
}

struct UserScoreDetailsResponseDTO: Content {
    let totalScore: Int
    let events: [ScoreEventDetailDTO]
}

struct ScoreEventDetailDTO: Content {
    let source: String
    let points: Int
    let date: Date
}
