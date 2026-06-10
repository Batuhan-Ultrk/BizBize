import Foundation

enum ProfileEndpoint: APIEndpoint {
    case getUser(id: UUID)
    case updateMe(UpdateUserProfileRequestDTO)
    case saveHints(SaveProfileHintsRequestDTO)
    case score(userId: UUID)

    var path: String {
        switch self {
        case let .getUser(id):
            return "/users/\(id.uuidString)"
        case .updateMe:
            return "/auth/me"
        case .saveHints:
            return "/auth/me/hints"
        case let .score(userId):
            return "/scores/\(userId.uuidString)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUser, .score:
            return .get
        case .updateMe:
            return .patch
        case .saveHints:
            return .post
        }
    }

    var body: Encodable? {
        switch self {
        case let .updateMe(request):
            return request
        case let .saveHints(request):
            return request
        case .getUser, .score:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
