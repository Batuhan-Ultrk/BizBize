import Foundation

protocol LeaderboardServiceProtocol {
    func getLeaderboard() async throws -> [LeaderboardEntryDTO]
    func getScore(userId: UUID) async throws -> UserScoreDTO
}

struct DefaultLeaderboardService: LeaderboardServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getLeaderboard() async throws -> [LeaderboardEntryDTO] {
        try await networkManager.request(
            LeaderboardEndpoint.leaderboard,
            responseType: [LeaderboardEntryDTO].self
        )
    }

    func getScore(userId: UUID) async throws -> UserScoreDTO {
        try await networkManager.request(
            LeaderboardEndpoint.score(userId: userId),
            responseType: UserScoreDTO.self
        )
    }
}

final class LeaderboardServiceContainer: ObservableObject {
    let service: LeaderboardServiceProtocol

    init(service: LeaderboardServiceProtocol) {
        self.service = service
    }
}
