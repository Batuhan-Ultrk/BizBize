import Foundation

enum AnnouncementEndpoint: APIEndpoint {
    case list(type: String?)
    case detail(id: UUID)
    case create(CreateAnnouncementRequestDTO)
    case rsvp(id: UUID, RsvpRequestDTO)

    var path: String {
        switch self {
        case .list, .create:
            return "/announcements"
        case let .detail(id):
            return "/announcements/\(id.uuidString)"
        case let .rsvp(id, _):
            return "/announcements/\(id.uuidString)/rsvp"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .detail:
            return .get
        case .create, .rsvp:
            return .post
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .list(type):
            guard let type else { return nil }
            return [URLQueryItem(name: "type", value: type)]
        case .detail, .create, .rsvp:
            return nil
        }
    }

    var body: Encodable? {
        switch self {
        case let .create(request):
            return request
        case let .rsvp(_, request):
            return request
        case .list, .detail:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
