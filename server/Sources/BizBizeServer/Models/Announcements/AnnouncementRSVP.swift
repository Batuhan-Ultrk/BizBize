import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

enum AnnouncementRSVPStatus: String, Codable, CaseIterable {
    case attending
    case notAttending
}

final class AnnouncementRSVP: Model, Content, @unchecked Sendable {
    static let schema = "announcement_rsvps"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "announcement_id")
    var announcement: Announcement

    @Parent(key: "user_id")
    var user: User

    @Enum(key: "status")
    var status: AnnouncementRSVPStatus

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        announcementID: Announcement.IDValue,
        userID: User.IDValue,
        status: AnnouncementRSVPStatus
    ) {
        self.id = id
        self.$announcement.id = announcementID
        self.$user.id = userID
        self.status = status
    }
}
