import Foundation

@MainActor
final class AnnouncementDetailViewModel: ObservableObject {
    @Published var announcement: AnnouncementDTO?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let announcementId: UUID
    private let announcementService: AnnouncementServiceProtocol

    init(announcementId: UUID, announcementService: AnnouncementServiceProtocol) {
        self.announcementId = announcementId
        self.announcementService = announcementService
    }

    func fetchDetail() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            announcement = try await announcementService.getAnnouncementDetail(id: announcementId)
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func sendRsvp(status: RsvpStatus) async {
        do {
            announcement = try await announcementService.sendRsvp(
                id: announcementId,
                request: RsvpRequestDTO(status: status.rawValue)
            )
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
