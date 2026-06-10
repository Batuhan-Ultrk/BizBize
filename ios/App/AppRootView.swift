import SwiftUI

struct AppRootView: View {
    @StateObject private var appSession: AppSession
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var announcementServiceContainer: AnnouncementServiceContainer
    @StateObject private var pollServiceContainer: PollServiceContainer
    @StateObject private var employeeDirectoryServiceContainer: EmployeeDirectoryServiceContainer
    @StateObject private var mysteryEmployeeServiceContainer: MysteryEmployeeServiceContainer
    @StateObject private var leaderboardViewModel: LeaderboardViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @State private var didFinishSplash = false

    init() {
        let tokenStorage = UserDefaultsTokenStorage()
        let appSession = AppSession(tokenStorage: tokenStorage)
        let networkManager = DefaultNetworkManager(tokenStorage: tokenStorage)
        let authService = DefaultAuthService(networkManager: networkManager)
        let homeService = DefaultHomeService(networkManager: networkManager)
        let announcementService = DefaultAnnouncementService(networkManager: networkManager)
        let pollService = DefaultPollService(networkManager: networkManager)
        let employeeDirectoryService = DefaultEmployeeDirectoryService(networkManager: networkManager)
        let mysteryEmployeeService = DefaultMysteryEmployeeService(networkManager: networkManager)
        let leaderboardService = DefaultLeaderboardService(networkManager: networkManager)
        let profileService = DefaultProfileService(networkManager: networkManager)

        _appSession = StateObject(wrappedValue: appSession)
        _authViewModel = StateObject(
            wrappedValue: AuthViewModel(
                authService: authService,
                appSession: appSession
            )
        )
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                homeService: homeService,
                appSession: appSession
            )
        )
        _announcementServiceContainer = StateObject(
            wrappedValue: AnnouncementServiceContainer(service: announcementService)
        )
        _pollServiceContainer = StateObject(
            wrappedValue: PollServiceContainer(service: pollService)
        )
        _employeeDirectoryServiceContainer = StateObject(
            wrappedValue: EmployeeDirectoryServiceContainer(service: employeeDirectoryService)
        )
        _mysteryEmployeeServiceContainer = StateObject(
            wrappedValue: MysteryEmployeeServiceContainer(service: mysteryEmployeeService)
        )
        _leaderboardViewModel = StateObject(
            wrappedValue: LeaderboardViewModel(
                leaderboardService: leaderboardService,
                appSession: appSession
            )
        )
        _profileViewModel = StateObject(
            wrappedValue: ProfileViewModel(
                profileService: profileService,
                appSession: appSession
            )
        )
    }

    var body: some View {
        Group {
            if didFinishSplash {
                if appSession.isAuthenticated {
                    MainTabView()
                } else {
                    AuthContainerView()
                }
            } else {
                SplashView {
                    didFinishSplash = true
                }
            }
        }
            .environmentObject(appSession)
            .environmentObject(authViewModel)
            .environmentObject(homeViewModel)
            .environmentObject(announcementServiceContainer)
            .environmentObject(pollServiceContainer)
            .environmentObject(employeeDirectoryServiceContainer)
            .environmentObject(mysteryEmployeeServiceContainer)
            .environmentObject(leaderboardViewModel)
            .environmentObject(profileViewModel)
    }
}
