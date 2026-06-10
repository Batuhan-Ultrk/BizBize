import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

enum AnnouncementType: String, Codable, CaseIterable {
    case birthday
    case gift
    case event
    case operational
}

final class Announcement: Model, Content, @unchecked Sendable {
    static let schema = "announcements"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "created_by_user_id")
    var createdByUser: User

    @Enum(key: "type")
    var type: AnnouncementType

    @Field(key: "title")
    var title: String

    @Field(key: "body")
    var body: String

    @OptionalField(key: "event_date")
    var eventDate: Date?

    @Field(key: "has_rsvp")
    var hasRsvp: Bool

    @Field(key: "target_user_ids")
    var targetUserIds: [UUID]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        createdByUserID: User.IDValue,
        type: AnnouncementType,
        title: String,
        body: String,
        eventDate: Date? = nil,
        hasRsvp: Bool,
        targetUserIds: [UUID] = []
    ) {
        self.id = id
        self.$createdByUser.id = createdByUserID
        self.type = type
        self.title = title
        self.body = body
        self.eventDate = eventDate
        self.hasRsvp = hasRsvp
        self.targetUserIds = targetUserIds
    }
}
