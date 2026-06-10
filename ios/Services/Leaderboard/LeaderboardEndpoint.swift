import Foundation

enum LeaderboardEndpoint: APIEndpoint {
    case leaderboard
    case score(userId: UUID)

    var path: String {
        switch self {
        case .leaderboard:
            return "/leaderboard"
        case let .score(userId):
            return "/scores/\(userId.uuidString)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var requiresAuthentication: Bool {
        true
    }
}
