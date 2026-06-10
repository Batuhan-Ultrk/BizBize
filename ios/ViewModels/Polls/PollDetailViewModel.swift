import Foundation

@MainActor
final class PollDetailViewModel: ObservableObject {
    @Published var poll: PollDTO?
    @Published var selectedOptionId: UUID?
    @Published var isLoading = false
    @Published var isVoting = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let pollId: UUID
    private let pollService: PollServiceProtocol

    init(pollId: UUID, pollService: PollServiceProtocol) {
        self.pollId = pollId
        self.pollService = pollService
    }

    func fetchDetail() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            let response = try await pollService.getPollDetail(id: pollId)
            poll = response
            selectedOptionId = response.myVoteOptionId
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func vote(option: PollOptionDTO) async {
        guard let poll else { return }

        isVoting = true
        alertMessage = nil
        showAlert = false

        do {
            let response: PollDTO
            if poll.type == PollType.dailyLunch.rawValue, let key = option.key {
                response = try await pollService.voteDailyLunch(
                    request: DailyLunchVoteRequestDTO(option: key)
                )
            } else {
                response = try await pollService.vote(
                    id: poll.id,
                    request: PollVoteRequestDTO(optionId: option.id)
                )
            }

            self.poll = response
            selectedOptionId = response.myVoteOptionId
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isVoting = false
    }
}
