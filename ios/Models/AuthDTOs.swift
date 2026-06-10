import Foundation

struct RegisterRequestDTO: Codable {
    let firstName: String
    let lastName: String
    let birthDate: Date
    let phoneNumber: String
    let email: String
    let password: String
}

struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}

struct AuthResponseDTO: Codable {
    let token: String
    let user: PublicUserDTO
}

struct PublicUserDTO: Codable, Identifiable {
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

struct PasswordResetRequestDTO: Codable {
    let email: String
}

struct PasswordResetResponseDTO: Codable {
    let message: String
}

struct PasswordResetConfirmDTO: Codable {
    let token: String
    let newPassword: String
}
