import Foundation

struct CreatePollRequestDTO: Codable {
    let question: String
    let options: [String]
    let expiresAt: Date
    let targetUserIds: [UUID]?
}
