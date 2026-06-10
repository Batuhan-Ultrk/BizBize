import Foundation

struct AnnouncementDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let createdByUserId: UUID
    let type: String
    let title: String
    let body: String
    let eventDate: Date?
    let hasRsvp: Bool
    let targetUserIds: [UUID]?
    let attendees: [UUID]
    let myRsvpStatus: String?
    let createdAt: Date
}

extension AnnouncementDTO {
    var typeTitle: String {
        AnnouncementType.displayName(for: type)
    }

    var typeIcon: HomeIconKind {
        AnnouncementType.icon(for: type)
    }

    var formattedCreatedAt: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    var formattedEventDate: String? {
        eventDate?.formatted(date: .abbreviated, time: .shortened)
    }
}

enum AnnouncementType: String, CaseIterable, Identifiable {
    case birthday
    case gift
    case event
    case operational

    var id: String { rawValue }

    var title: String {
        Self.displayName(for: rawValue)
    }

    var icon: HomeIconKind {
        Self.icon(for: rawValue)
    }

    var supportsRsvp: Bool {
        self == .gift || self == .event
    }

    static func displayName(for type: String) -> String {
        switch type {
        case "birthday":
            return "Doğum Günü"
        case "gift":
            return "Hediye"
        case "event":
            return "Etkinlik"
        case "operational":
            return "Operasyonel"
        default:
            return type
        }
    }

    static func icon(for type: String) -> HomeIconKind {
        switch type {
        case "birthday":
            return .birthday
        case "gift":
            return .gift
        case "event":
            return .event
        case "operational":
            return .operational
        default:
            return .announcements
        }
    }
}

enum RsvpStatus: String {
    case attending
    case notAttending
}
