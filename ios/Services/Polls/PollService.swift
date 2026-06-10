import Foundation

protocol PollServiceProtocol {
    func getPolls(type: String?) async throws -> [PollDTO]
    func getPollDetail(id: UUID) async throws -> PollDTO
    func createPoll(request: CreatePollRequestDTO) async throws -> PollDTO
    func vote(id: UUID, request: PollVoteRequestDTO) async throws -> PollDTO
    func getDailyLunchPoll() async throws -> PollDTO
    func voteDailyLunch(request: DailyLunchVoteRequestDTO) async throws -> PollDTO
}

struct DefaultPollService: PollServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getPolls(type: String?) async throws -> [PollDTO] {
        try await networkManager.request(
            PollEndpoint.list(type: type),
            responseType: [PollDTO].self
        )
    }

    func getPollDetail(id: UUID) async throws -> PollDTO {
        try await networkManager.request(
            PollEndpoint.detail(id: id),
            responseType: PollDTO.self
        )
    }

    func createPoll(request: CreatePollRequestDTO) async throws -> PollDTO {
        try await networkManager.request(
            PollEndpoint.create(request),
            responseType: PollDTO.self
        )
    }

    func vote(id: UUID, request: PollVoteRequestDTO) async throws -> PollDTO {
        try await networkManager.request(
            PollEndpoint.vote(id: id, request),
            responseType: PollDTO.self
        )
    }

    func getDailyLunchPoll() async throws -> PollDTO {
        try await networkManager.request(
            PollEndpoint.dailyLunch,
            responseType: PollDTO.self
        )
    }

    func voteDailyLunch(request: DailyLunchVoteRequestDTO) async throws -> PollDTO {
        try await networkManager.request(
            PollEndpoint.dailyLunchVote(request),
            responseType: PollDTO.self
        )
    }
}

final class PollServiceContainer: ObservableObject {
    let service: PollServiceProtocol

    init(service: PollServiceProtocol) {
        self.service = service
    }
}
