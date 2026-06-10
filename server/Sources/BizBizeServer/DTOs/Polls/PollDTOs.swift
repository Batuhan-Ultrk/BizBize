import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct CreatePollRequestDTO: Content {
    let question: String
    let options: [String]
    let expiresAt: Date?
    let targetUserIds: [UUID]?
}

struct PollResponseDTO: Content {
    let id: UUID
    let createdByUserId: UUID?
    let type: PollType
    let question: String
    let options: [PollOptionResponseDTO]
    let expiresAt: Date?
    let targetUserIds: [UUID]
    let dayKey: String?
    let isClosed: Bool
    let myVoteOptionId: UUID?
    let createdAt: Date?
}

struct PollOptionResponseDTO: Content {
    let id: UUID
    let text: String
    let key: String?
    let displayOrder: Int
    let voteCount: Int
}

struct VotePollRequestDTO: Content {
    let optionId: UUID
}

struct VoteDailyLunchPollRequestDTO: Content {
    let option: DailyLunchPollOption
}

struct PollListQueryDTO: Content {
    let type: PollType?
}

enum DailyLunchPollOption: String, Codable, CaseIterable {
    case home
    case outside
    case order
}
