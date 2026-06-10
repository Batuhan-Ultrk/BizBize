import Foundation

@MainActor
final class CreateAnnouncementViewModel: ObservableObject {
    @Published var title = "" {
        didSet { titleError = nil }
    }
    @Published var body = "" {
        didSet { bodyError = nil }
    }
    @Published var selectedType: AnnouncementType = .event {
        didSet {
            if !selectedType.supportsRsvp {
                hasRsvp = false
            }
        }
    }
    @Published var eventDate = Date()
    @Published var includesEventDate = false
    @Published var hasRsvp = true
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var titleError: String?
    @Published var bodyError: String?

    private let announcementService: AnnouncementServiceProtocol

    init(announcementService: AnnouncementServiceProtocol) {
        self.announcementService = announcementService
    }

    func createAnnouncement() async -> Bool {
        guard validate() else { return false }

        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            _ = try await announcementService.createAnnouncement(
                request: CreateAnnouncementRequestDTO(
                    type: selectedType.rawValue,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    body: body.trimmingCharacters(in: .whitespacesAndNewlines),
                    eventDate: includesEventDate ? eventDate : nil,
                    hasRsvp: selectedType.supportsRsvp ? hasRsvp : false,
                    targetUserIds: []
                )
            )
            isLoading = false
            return true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
            isLoading = false
            return false
        }
    }

    private func validate() -> Bool {
        titleError = nil
        bodyError = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        var isValid = true

        if trimmedTitle.isEmpty {
            titleError = "Başlık alanı zorunludur."
            isValid = false
        } else if trimmedTitle.count > 140 {
            titleError = "Başlık en fazla 140 karakter olabilir."
            isValid = false
        }

        if trimmedBody.isEmpty {
            bodyError = "İçerik alanı zorunludur."
            isValid = false
        }

        return isValid
    }
}
