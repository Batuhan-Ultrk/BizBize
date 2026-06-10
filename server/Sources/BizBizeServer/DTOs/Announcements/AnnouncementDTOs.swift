import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct CreateAnnouncementRequestDTO: Content {
    let type: AnnouncementType
    let title: String
    let body: String
    let eventDate: Date?
    let hasRsvp: Bool?
    let targetUserIds: [UUID]?
}

struct AnnouncementResponseDTO: Content {
    let id: UUID
    let createdByUserId: UUID
    let type: AnnouncementType
    let title: String
    let body: String
    let eventDate: Date?
    let hasRsvp: Bool
    let targetUserIds: [UUID]
    let attendees: [UUID]
    let myRsvpStatus: AnnouncementRSVPStatus?
    let createdAt: Date?
}

struct RSVPAnnouncementRequestDTO: Content {
    let status: AnnouncementRSVPStatus
}

struct AnnouncementListQueryDTO: Content {
    let type: AnnouncementType?
}
