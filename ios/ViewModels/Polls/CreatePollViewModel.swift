import Foundation

@MainActor
final class CreatePollViewModel: ObservableObject {
    @Published var question = "" {
        didSet { questionError = nil }
    }
    @Published var options: [String] = ["", ""] {
        didSet { optionsError = nil }
    }
    @Published var expiresAt = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var questionError: String?
    @Published var optionsError: String?

    private let pollService: PollServiceProtocol

    init(pollService: PollServiceProtocol) {
        self.pollService = pollService
    }

    func addOption() {
        guard options.count < 5 else { return }
        options.append("")
    }

    func removeOption(at index: Int) {
        guard options.count > 2, options.indices.contains(index) else { return }
        options.remove(at: index)
    }

    func createPoll() async -> Bool {
        guard validate() else { return false }

        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            _ = try await pollService.createPoll(
                request: CreatePollRequestDTO(
                    question: question.trimmingCharacters(in: .whitespacesAndNewlines),
                    options: normalizedOptions,
                    expiresAt: expiresAt,
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

    private var normalizedOptions: [String] {
        options.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func validate() -> Bool {
        questionError = nil
        optionsError = nil

        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = normalizedOptions
        var isValid = true

        if trimmedQuestion.isEmpty {
            questionError = "Soru alanı zorunludur."
            isValid = false
        }

        if normalized.count < 2 {
            optionsError = "En az 2 seçenek ekleyiniz."
            isValid = false
        } else if normalized.count > 5 {
            optionsError = "En fazla 5 seçenek ekleyebilirsiniz."
            isValid = false
        } else if Set(normalized.map { $0.lowercased() }).count != normalized.count {
            optionsError = "Seçenekler tekrarlı olamaz."
            isValid = false
        }

        return isValid
    }
}
