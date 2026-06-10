import Foundation

struct MysteryChallengeDTO: Codable, Identifiable {
    let id: UUID
    let question: String
    let options: [String]
    let hintCount: Int
    let expiresAt: Date
}

struct MysteryGuessRequestDTO: Codable {
    let guess: String
}

struct MysteryGuessResponseDTO: Codable {
    let correct: Bool
    let earnedPoints: Int
    let badgeAwarded: String?
}

extension MysteryChallengeDTO {
    var formattedExpiresAt: String {
        expiresAt.formatted(date: .omitted, time: .shortened)
    }
}
