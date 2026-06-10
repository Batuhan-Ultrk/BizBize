import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var announcementServiceContainer: AnnouncementServiceContainer
    @EnvironmentObject private var pollServiceContainer: PollServiceContainer
    @EnvironmentObject private var employeeDirectoryServiceContainer: EmployeeDirectoryServiceContainer
    @EnvironmentObject private var mysteryEmployeeServiceContainer: MysteryEmployeeServiceContainer

    private let quickActions = [
        HomeQuickAction(icon: .announcements, title: "Duyurular"),
        HomeQuickAction(icon: .surveys, title: "Anketler"),
        HomeQuickAction(icon: .mysteryEmployee, title: "Gizemli Çalışan"),
        HomeQuickAction(icon: .directory, title: "Çalışan Rehberi")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bizBizeScreenBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        navigationHeader
                        greetingSection
                        statsSection
                        FoodPollCard()
                        quickActionsSection
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await viewModel.fetchHomeInfo()
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.fetchHomeInfo()
            }
            .alert("Hata", isPresented: $viewModel.showAlert) {
                Button("Tamam", role: .cancel) {
                    viewModel.alertMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .tint(Color.bizBizeButtonStart)
            .navigationDestination(for: HomeQuickAction.self) { action in
                if action.icon == .announcements {
                    AnnouncementListView(
                        viewModel: AnnouncementListViewModel(
                            announcementService: announcementServiceContainer.service
                        )
                    )
                } else if action.icon == .surveys {
                    PollListView(
                        viewModel: PollListViewModel(
                            pollService: pollServiceContainer.service
                        )
                    )
                } else if action.icon == .directory {
                    EmployeeDirectoryView(
                        viewModel: EmployeeDirectoryViewModel(
                            employeeDirectoryService: employeeDirectoryServiceContainer.service
                        )
                    )
                } else if action.icon == .mysteryEmployee {
                    MysteryEmployeeView(
                        viewModel: MysteryEmployeeViewModel(
                            mysteryEmployeeService: mysteryEmployeeServiceContainer.service
                        )
                    )
                } else {
                    PlaceholderDestinationView(title: action.title, icon: action.icon)
                }
            }
        }
    }

    private var navigationHeader: some View {
        HStack {
            Color.clear
                .frame(width: 44, height: 44)

            Spacer()

            Text("Ana Sayfa")
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeInk)

            Spacer()

            Button {
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.bizBizeInk)
                        .frame(width: 44, height: 44)

                    if viewModel.announcementCount > 0 {
                        Text(badgeText)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(.red)
                            .clipShape(Circle())
                            .offset(x: -5, y: 5)
                    }
                }
            }
            .accessibilityLabel("Bildirimler")
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(greetingTitle)
                    .font(.title2.bold())
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                HomeIconView(kind: .wave, size: 24)
            }

            Text("Bugün ofiste neler oluyor?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.bizBizeMuted)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 14) {
            HomeStatCard(
                icon: .birthday,
                value: "\(viewModel.birthdayCount)",
                title: "Bugün\nDoğum Günü"
            )

            HomeStatCard(
                icon: .surveys,
                value: "\(viewModel.activeSurveyCount)",
                title: "Aktif\nAnket"
            )

            HomeStatCard(
                icon: .mysteryEmployee,
                value: viewModel.mysteryEmployeeTime,
                title: "Gizemli\nÇalışan"
            )
        }
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
    }

    private var quickActionsSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(quickActions) { action in
                NavigationLink(value: action) {
                    HomeQuickActionCard(icon: action.icon, title: action.title)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var greetingTitle: String {
        viewModel.firstName.isEmpty ? "Merhaba" : "Merhaba \(viewModel.firstName)"
    }

    private var badgeText: String {
        viewModel.announcementCount > 9 ? "9+" : "\(viewModel.announcementCount)"
    }
}

private struct HomeQuickAction: Hashable, Identifiable {
    let id = UUID()
    let icon: HomeIconKind
    let title: String
}

private struct PlaceholderDestinationView: View {
    let title: String
    let icon: HomeIconKind

    var body: some View {
        ZStack {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 14) {
                HomeIconView(kind: icon, size: 56)

                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Text("Bu ekran yakında eklenecek.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.bizBizeMuted)
            }
            .padding(24)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
