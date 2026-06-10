import Foundation

struct PollVoteRequestDTO: Codable {
    let optionId: UUID
}

struct DailyLunchVoteRequestDTO: Codable {
    let option: String
}
