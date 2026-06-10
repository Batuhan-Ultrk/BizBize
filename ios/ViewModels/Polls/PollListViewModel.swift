import Foundation

@MainActor
final class PollListViewModel: ObservableObject {
    @Published var polls: [PollDTO] = []
    @Published var selectedType: String?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let pollService: PollServiceProtocol

    init(pollService: PollServiceProtocol) {
        self.pollService = pollService
    }

    func fetchPolls() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            polls = try await pollService.getPolls(type: selectedType)
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func selectType(_ type: String?) async {
        selectedType = type
        await fetchPolls()
    }
}
