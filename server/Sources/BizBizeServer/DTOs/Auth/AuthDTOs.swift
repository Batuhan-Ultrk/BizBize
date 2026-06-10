import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct RegisterRequestDTO: Content {
    let firstName: String
    let lastName: String
    let birthDate: Date
    let phoneNumber: String
    let email: String
    let password: String
}

struct LoginRequestDTO: Content {
    let email: String
    let password: String
}

struct AuthResponseDTO: Content {
    let token: String
    let user: PublicUserDTO
}

struct PublicUserDTO: Content {
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
}

struct PasswordResetRequestDTO: Content {
    let email: String
}

struct PasswordResetResponseDTO: Content {
    let message: String
}

struct PasswordResetConfirmDTO: Content {
    let token: String
    let newPassword: String
}
