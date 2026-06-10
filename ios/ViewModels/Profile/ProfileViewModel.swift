import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: PublicUserDTO?
    @Published var score: UserScoreDTO?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var selectedWorkMode: WorkMode = .office
    @Published var hintTexts: [String] = Array(repeating: "", count: 5)
    @Published var hintTypes: [ProfileHintType] = [.habit, .seniority, .yesno, .hobby, .funFact]
    @Published var hintValidationMessage: String?
    @Published var isSavingHints = false
    @Published var successMessage: String?
    @Published var showSuccessAlert = false

    private let profileService: ProfileServiceProtocol
    private let appSession: AppSession

    init(profileService: ProfileServiceProtocol, appSession: AppSession) {
        self.profileService = profileService
        self.appSession = appSession
        self.user = appSession.currentUser
    }

    func fetchProfile() async {
        guard let userId = appSession.currentUser?.id else { return }

        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            async let profile = profileService.getUser(id: userId)
            async let userScore = profileService.getScore(userId: userId)

            let fetchedUser = try await profile
            user = fetchedUser
            appSession.updateCurrentUser(fetchedUser)
            score = try await userScore
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }

    func saveHints() async {
        let trimmedHints = hintTexts.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let filledHints = trimmedHints.enumerated().compactMap { index, text -> ProfileHintRequestDTO? in
            guard !text.isEmpty else { return nil }

            return ProfileHintRequestDTO(
                type: hintTypes[index].rawValue,
                text: text,
                revealOrder: index + 1
            )
        }

        guard filledHints.count >= 3 else {
            hintValidationMessage = "En az 3 ipucu girmelisiniz."
            return
        }

        guard filledHints.count <= 5 else {
            hintValidationMessage = "En fazla 5 ipucu girebilirsiniz."
            return
        }

        hintValidationMessage = nil
        isSavingHints = true
        alertMessage = nil
        showAlert = false

        do {
            try await profileService.saveHints(
                request: SaveProfileHintsRequestDTO(hints: filledHints)
            )
            successMessage = "İpuçların başarıyla kaydedildi."
            showSuccessAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isSavingHints = false
    }

    func clearHintValidation() {
        hintValidationMessage = nil
    }

    var displayName: String {
        guard let user else { return "Profilim" }
        return "\(user.firstName) \(user.lastName)"
    }

    var title: String {
        user?.department ?? "Ekip Üyesi"
    }

    var email: String {
        user?.email ?? "-"
    }

    var phoneNumber: String {
        user?.phoneNumber ?? "-"
    }

    var birthDate: String {
        user?.birthDate.formatted(date: .abbreviated, time: .omitted) ?? "-"
    }

    var department: String {
        user?.department ?? "Belirtilmedi"
    }

    var correctGuessCount: Int {
        score?.events.filter { $0.source == "challenge" && $0.points > 0 }.count ?? 0
    }

    var pollParticipationCount: Int {
        score?.events.filter { $0.source == "poll" }.count ?? 0
    }

    var announcementCount: Int {
        score?.events.filter { $0.source == "announcement" }.count ?? 0
    }
}

enum WorkMode: String, CaseIterable, Identifiable {
    case office
    case hybrid
    case remote

    var id: String { rawValue }

    var title: String {
        switch self {
        case .office:
            return "Ofiste"
        case .hybrid:
            return "Hibrit"
        case .remote:
            return "Uzaktan"
        }
    }

    var icon: String {
        switch self {
        case .office:
            return "building.2.fill"
        case .hybrid:
            return "house.and.flag.fill"
        case .remote:
            return "house.fill"
        }
    }
}
