import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
            .tabItem {
                Label(L10n.text("main.home.title"), systemImage: "house.fill")
            }

            LeaderboardView()
            .tabItem {
                Label("Liderlik", systemImage: "trophy.fill")
            }

            ProfileView()
            .tabItem {
                Label(L10n.text("main.profile.title"), systemImage: "person.crop.circle.fill")
            }
        }
        .tint(Color.bizBizeButtonStart)
    }
}
