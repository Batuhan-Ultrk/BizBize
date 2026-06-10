import Foundation

enum MysteryEmployeeEndpoint: APIEndpoint {
    case challenge
    case detail(id: UUID)
    case guess(id: UUID, MysteryGuessRequestDTO)

    var path: String {
        switch self {
        case .challenge:
            return "/challenges"
        case let .detail(id):
            return "/challenges/\(id.uuidString)"
        case let .guess(id, _):
            return "/challenges/\(id.uuidString)/guess"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .challenge, .detail:
            return .get
        case .guess:
            return .post
        }
    }

    var body: Encodable? {
        switch self {
        case let .guess(_, request):
            return request
        case .challenge, .detail:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
