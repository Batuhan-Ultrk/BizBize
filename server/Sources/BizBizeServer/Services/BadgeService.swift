import Fluent
import Vapor
import Foundation

struct BadgeService {
    static func checkAndAwardPermanentBadges(userID: UUID, on db: any Database) async throws {
        // 1. Detective
        let correctGuesses = try await Guess.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$isCorrect == true)
            .count()
        if correctGuesses >= 10 {
            let badgeType = BadgeType.detective.rawValue
            let exists = try await Badge.query(on: db)
                .filter(\.$user.$id == userID)
                .filter(\.$type == badgeType)
                .first() != nil
            if !exists {
                let badge = Badge(userID: userID, type: badgeType)
                try await badge.save(on: db)
            }
        }

        // 2. Social Butterfly
        let pollVotes = try await PollVote.query(on: db)
            .filter(\.$user.$id == userID)
            .count()
        if pollVotes >= 20 {
            let badgeType = BadgeType.socialButterfly.rawValue
            let exists = try await Badge.query(on: db)
                .filter(\.$user.$id == userID)
                .filter(\.$type == badgeType)
                .first() != nil
            if !exists {
                let badge = Badge(userID: userID, type: badgeType)
                try await badge.save(on: db)
            }
        }

        // 3. Team Player
        let rsvps = try await AnnouncementRSVP.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$status == .attending)
            .with(\.$announcement)
            .all()
        let eventCount = rsvps.filter { $0.announcement.type == .event }.count
        if eventCount >= 10 {
            let badgeType = BadgeType.teamPlayer.rawValue
            let exists = try await Badge.query(on: db)
                .filter(\.$user.$id == userID)
                .filter(\.$type == badgeType)
                .first() != nil
            if !exists {
                let badge = Badge(userID: userID, type: badgeType)
                try await badge.save(on: db)
            }
        }
    }
}
