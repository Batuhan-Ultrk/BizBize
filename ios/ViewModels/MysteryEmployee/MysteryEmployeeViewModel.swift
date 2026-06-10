import Foundation

@MainActor
final class MysteryEmployeeViewModel: ObservableObject {
    @Published var challenge: MysteryChallengeDTO?
    @Published var selectedOption: String?
    @Published var guessResult: MysteryGuessResponseDTO?
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let mysteryEmployeeService: MysteryEmployeeServiceProtocol

    init(mysteryEmployeeService: MysteryEmployeeServiceProtocol) {
        self.mysteryEmployeeService = mysteryEmployeeService
    }

    func fetchChallenge() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            challenge = try await mysteryEmployeeService.getChallenge()
            selectedOption = nil
            guessResult = nil
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func submitGuess() async {
        guard let challenge else { return }

        guard let selectedOption else {
            alertMessage = "Lütfen bir çalışan seçiniz."
            showAlert = true
            return
        }

        isSubmitting = true
        alertMessage = nil
        showAlert = false

        do {
            guessResult = try await mysteryEmployeeService.submitGuess(
                id: challenge.id,
                request: MysteryGuessRequestDTO(guess: selectedOption)
            )
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isSubmitting = false
    }

    var canSubmit: Bool {
        selectedOption != nil && !isSubmitting
    }
}
