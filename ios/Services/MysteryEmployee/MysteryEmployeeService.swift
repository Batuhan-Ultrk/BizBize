import Foundation

protocol MysteryEmployeeServiceProtocol {
    func getChallenge() async throws -> MysteryChallengeDTO
    func getChallengeDetail(id: UUID) async throws -> MysteryChallengeDTO
    func submitGuess(id: UUID, request: MysteryGuessRequestDTO) async throws -> MysteryGuessResponseDTO
}

struct DefaultMysteryEmployeeService: MysteryEmployeeServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getChallenge() async throws -> MysteryChallengeDTO {
        try await networkManager.request(
            MysteryEmployeeEndpoint.challenge,
            responseType: MysteryChallengeDTO.self
        )
    }

    func getChallengeDetail(id: UUID) async throws -> MysteryChallengeDTO {
        try await networkManager.request(
            MysteryEmployeeEndpoint.detail(id: id),
            responseType: MysteryChallengeDTO.self
        )
    }

    func submitGuess(id: UUID, request: MysteryGuessRequestDTO) async throws -> MysteryGuessResponseDTO {
        try await networkManager.request(
            MysteryEmployeeEndpoint.guess(id: id, request),
            responseType: MysteryGuessResponseDTO.self
        )
    }
}

final class MysteryEmployeeServiceContainer: ObservableObject {
    let service: MysteryEmployeeServiceProtocol

    init(service: MysteryEmployeeServiceProtocol) {
        self.service = service
    }
}
