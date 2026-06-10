import Foundation

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntryDTO] = []
    @Published var userScore: UserScoreDTO?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?

    private let leaderboardService: LeaderboardServiceProtocol
    private let appSession: AppSession

    init(leaderboardService: LeaderboardServiceProtocol, appSession: AppSession) {
        self.leaderboardService = leaderboardService
        self.appSession = appSession
    }

    func fetchLeaderboard() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            async let leaderboard = leaderboardService.getLeaderboard()
            async let score = currentUserScore()

            entries = try await leaderboard.sorted { $0.rank < $1.rank }
            userScore = try await score
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func displayName(for entry: LeaderboardEntryDTO) -> String {
        if let displayName = entry.displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !displayName.isEmpty {
            return displayName
        }

        let backendName = [entry.firstName, entry.lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if !backendName.isEmpty {
            return backendName
        }

        if entry.userId == appSession.currentUser?.id {
            return [appSession.currentUser?.firstName, appSession.currentUser?.lastName]
                .compactMap { $0 }
                .joined(separator: " ")
        }

        let fallbackId = entry.userIdRaw.isEmpty ? "\(entry.rank)" : String(entry.userIdRaw.prefix(4))
        return "Kullanıcı \(fallbackId)"
    }

    var totalScore: Int {
        userScore?.totalScore ?? entries.first(where: { $0.userId == appSession.currentUser?.id })?.score ?? 0
    }

    var correctGuessCount: Int {
        userScore?.events.filter { $0.source == "challenge" && $0.points > 0 }.count ?? 0
    }

    var gameParticipationCount: Int {
        userScore?.events.filter { $0.source == "challenge" }.count ?? 0
    }

    private func currentUserScore() async throws -> UserScoreDTO? {
        guard let userId = appSession.currentUser?.id else { return nil }
        return try await leaderboardService.getScore(userId: userId)
    }
}
