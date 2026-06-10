import Fluent
import Vapor
import Foundation

struct ScoreService {
    static func awardPoints(
        userID: UUID,
        points: Int,
        type: String,
        sourceID: UUID?,
        engagementPoints: Int = 0,
        on db: any Database
    ) async throws {
        if let sourceID = sourceID {
            let existing = try await ScoreEvent.query(on: db)
                .filter(\.$user.$id == userID)
                .filter(\.$sourceId == sourceID)
                .filter(\.$type == type)
                .first()
            if existing != nil {
                return
            }
        }

        let event = ScoreEvent(
            userID: userID,
            points: points,
            type: type,
            sourceId: sourceID
        )
        try await event.save(on: db)

        if let score = try await UserScore.query(on: db)
            .filter(\.$user.$id == userID)
            .first()
        {
            score.weeklyPoints += points
            score.totalPoints += points
            score.monthlyEngagementScore += engagementPoints
            try await score.save(on: db)
        } else {
            let score = UserScore(
                userID: userID,
                weeklyPoints: points,
                totalPoints: points,
                monthlyEngagementScore: engagementPoints
            )
            try await score.save(on: db)
        }

        try await BadgeService.checkAndAwardPermanentBadges(userID: userID, on: db)
    }
}
