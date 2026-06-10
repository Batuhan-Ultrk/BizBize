import Foundation

protocol ProfileServiceProtocol {
    func getUser(id: UUID) async throws -> PublicUserDTO
    func updateUser(id: UUID, request: UpdateUserProfileRequestDTO) async throws -> PublicUserDTO
    func saveHints(request: SaveProfileHintsRequestDTO) async throws
    func getScore(userId: UUID) async throws -> UserScoreDTO
}

struct DefaultProfileService: ProfileServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getUser(id: UUID) async throws -> PublicUserDTO {
        try await networkManager.request(
            ProfileEndpoint.getUser(id: id),
            responseType: PublicUserDTO.self
        )
    }

    func updateUser(id: UUID, request: UpdateUserProfileRequestDTO) async throws -> PublicUserDTO {
        try await networkManager.request(
            ProfileEndpoint.updateMe(request),
            responseType: PublicUserDTO.self
        )
    }

    func saveHints(request: SaveProfileHintsRequestDTO) async throws {
        _ = try await networkManager.request(
            ProfileEndpoint.saveHints(request),
            responseType: EmptyResponse.self
        )
    }

    func getScore(userId: UUID) async throws -> UserScoreDTO {
        try await networkManager.request(
            ProfileEndpoint.score(userId: userId),
            responseType: UserScoreDTO.self
        )
    }
}
