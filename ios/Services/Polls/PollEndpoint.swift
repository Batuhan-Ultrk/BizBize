import Foundation

enum PollEndpoint: APIEndpoint {
    case list(type: String?)
    case detail(id: UUID)
    case create(CreatePollRequestDTO)
    case vote(id: UUID, PollVoteRequestDTO)
    case dailyLunch
    case dailyLunchVote(DailyLunchVoteRequestDTO)

    var path: String {
        switch self {
        case .list, .create:
            return "/polls"
        case let .detail(id):
            return "/polls/\(id.uuidString)"
        case let .vote(id, _):
            return "/polls/\(id.uuidString)/vote"
        case .dailyLunch:
            return "/polls/daily-lunch"
        case .dailyLunchVote:
            return "/polls/daily-lunch/vote"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .detail, .dailyLunch:
            return .get
        case .create, .vote, .dailyLunchVote:
            return .post
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .list(type):
            guard let type else { return nil }
            return [URLQueryItem(name: "type", value: type)]
        case .detail, .create, .vote, .dailyLunch, .dailyLunchVote:
            return nil
        }
    }

    var body: Encodable? {
        switch self {
        case let .create(request):
            return request
        case let .vote(_, request):
            return request
        case let .dailyLunchVote(request):
            return request
        case .list, .detail, .dailyLunch:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
