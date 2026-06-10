import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var birthdayCount: Int = 0
    @Published var activeSurveyCount: Int = 0
    @Published var announcementCount: Int = 0
    @Published var mysteryEmployeeTime: String = "15:00"
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String?

    private let homeService: HomeServiceProtocol
    private let appSession: AppSession

    init(homeService: HomeServiceProtocol, appSession: AppSession) {
        self.homeService = homeService
        self.appSession = appSession
        self.firstName = appSession.currentUser?.firstName ?? ""
    }

    func fetchHomeInfo() async {
        isLoading = true
        alertMessage = nil
        showAlert = false

        do {
            let response = try await homeService.getHomeInfo()
            let responseFirstName = response.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            firstName = responseFirstName.isEmpty ? (appSession.currentUser?.firstName ?? "") : responseFirstName
            birthdayCount = response.birthdayCount
            activeSurveyCount = response.activeSurveyCount
            announcementCount = response.announcementCount
            let responseMysteryTime = response.mysteryEmployeeTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            mysteryEmployeeTime = responseMysteryTime.isEmpty ? "15:00" : responseMysteryTime
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }
}
