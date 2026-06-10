import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct HintResponseDTO: Content {
    let id: UUID
    let type: String
    let revealOrder: Int
    let text: String?
    let isRevealed: Bool
    let secondsUntilReveal: Int?
}

struct ChallengeResponseDTO: Content {
    let id: UUID
    let dayKey: String
    let hints: [HintResponseDTO]
    let candidates: [PublicUserDTO]
    let isGuessed: Bool
    let myGuess: GuessResponseDTO?
    let revealedUser: PublicUserDTO?
}

struct GuessResponseDTO: Content {
    let id: UUID
    let guessedUserId: UUID
    let isCorrect: Bool
    let isFirstCorrect: Bool
    let timestamp: Date
}

struct SubmitGuessRequestDTO: Content {
    let guessedUserId: UUID
}

extension SubmitGuessRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("guessedUserId", as: UUID.self, is: .valid)
    }
}
