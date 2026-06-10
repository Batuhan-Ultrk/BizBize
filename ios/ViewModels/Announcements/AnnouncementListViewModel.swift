import Foundation

@MainActor
final class AnnouncementListViewModel: ObservableObject {
    @Published var announcements: [AnnouncementDTO] = []
    @Published var selectedType: String?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let announcementService: AnnouncementServiceProtocol

    init(announcementService: AnnouncementServiceProtocol) {
        self.announcementService = announcementService
    }

    func fetchAnnouncements() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            announcements = try await announcementService.getAnnouncements(type: selectedType)
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func selectType(_ type: String?) async {
        selectedType = type
        await fetchAnnouncements()
    }

    func sendRsvp(id: UUID, status: RsvpStatus) async {
        do {
            let updated = try await announcementService.sendRsvp(
                id: id,
                request: RsvpRequestDTO(status: status.rawValue)
            )
            if let index = announcements.firstIndex(where: { $0.id == updated.id }) {
                announcements[index] = updated
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
