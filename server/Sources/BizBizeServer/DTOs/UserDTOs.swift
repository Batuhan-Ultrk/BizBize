import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct BadgeResponseDTO: Content {
    let id: UUID
    let type: String
    let earnedAt: Date
    let periodLabel: String?
}

struct ScoreEventResponseDTO: Content {
    let id: UUID
    let points: Int
    let type: String
    let createdAt: Date
}

struct UserDetailResponseDTO: Content {
    let id: UUID
    let firstName: String
    let lastName: String
    let birthDate: Date
    let phoneNumber: String
    let email: String
    let department: String?
    let startDate: Date?
    let profilePhoto: String?
    let createdAt: Date?
    let weeklyPoints: Int
    let totalPoints: Int
    let badges: [BadgeResponseDTO]
    let scoreHistory: [ScoreEventResponseDTO]?
    let hints: [HintItemDTO]? // Only returned for the current user's profile view
}

struct HintItemDTO: Content {
    let type: String
    let text: String
    let revealOrder: Int
}

struct UpdateProfileRequestDTO: Content {
    let department: String?
    let startDate: Date?
    let profilePhoto: String?
}

struct SaveHintItemDTO: Content {
    let type: String
    let text: String
    let revealOrder: Int
}

struct SaveHintsRequestDTO: Content {
    let hints: [SaveHintItemDTO]
}

extension UpdateProfileRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        // Optional validations can go here if needed, but none are strictly required.
    }
}

extension SaveHintsRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        // Must contain between 3 and 5 hints
        validations.add("hints", as: [SaveHintItemDTO].self, is: .count(3...5))
    }
}
