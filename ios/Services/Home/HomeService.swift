import Foundation

protocol HomeServiceProtocol {
    func getHomeInfo() async throws -> HomeInfoResponseDTO
}

struct DefaultHomeService: HomeServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getHomeInfo() async throws -> HomeInfoResponseDTO {
        try await networkManager.request(
            HomeEndpoint.anasayfaBilgiGetir,
            responseType: HomeInfoResponseDTO.self
        )
    }
}
