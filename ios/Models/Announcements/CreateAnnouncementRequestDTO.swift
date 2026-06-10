import Foundation

struct CreateAnnouncementRequestDTO: Codable {
    let type: String
    let title: String
    let body: String
    let eventDate: Date?
    let hasRsvp: Bool?
    let targetUserIds: [UUID]?
}
