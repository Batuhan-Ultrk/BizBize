import Foundation

protocol AnnouncementServiceProtocol {
    func getAnnouncements(type: String?) async throws -> [AnnouncementDTO]
    func getAnnouncementDetail(id: UUID) async throws -> AnnouncementDTO
    func createAnnouncement(request: CreateAnnouncementRequestDTO) async throws -> AnnouncementDTO
    func sendRsvp(id: UUID, request: RsvpRequestDTO) async throws -> AnnouncementDTO
}

struct DefaultAnnouncementService: AnnouncementServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }

    func getAnnouncements(type: String?) async throws -> [AnnouncementDTO] {
        try await networkManager.request(
            AnnouncementEndpoint.list(type: type),
            responseType: [AnnouncementDTO].self
        )
    }

    func getAnnouncementDetail(id: UUID) async throws -> AnnouncementDTO {
        try await networkManager.request(
            AnnouncementEndpoint.detail(id: id),
            responseType: AnnouncementDTO.self
        )
    }

    func createAnnouncement(request: CreateAnnouncementRequestDTO) async throws -> AnnouncementDTO {
        try await networkManager.request(
            AnnouncementEndpoint.create(request),
            responseType: AnnouncementDTO.self
        )
    }

    func sendRsvp(id: UUID, request: RsvpRequestDTO) async throws -> AnnouncementDTO {
        try await networkManager.request(
            AnnouncementEndpoint.rsvp(id: id, request),
            responseType: AnnouncementDTO.self
        )
    }
}

final class AnnouncementServiceContainer: ObservableObject {
    let service: AnnouncementServiceProtocol

    init(service: AnnouncementServiceProtocol) {
        self.service = service
    }
}
