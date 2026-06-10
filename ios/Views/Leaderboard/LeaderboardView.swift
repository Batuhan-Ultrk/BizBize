import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var viewModel: LeaderboardViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bizBizeScreenBackground
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Liderlik Tablosu")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchLeaderboard()
            }
            .refreshable {
                await viewModel.fetchLeaderboard()
            }
            .alert("Hata", isPresented: $viewModel.showAlert) {
                Button("Tamam", role: .cancel) {
                    viewModel.alertMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .tint(Color.bizBizeButtonStart)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.entries.isEmpty {
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Color.bizBizeButtonStart)

                Text("Liderlik tablosu yükleniyor...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }
        } else {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    scoreSummaryCard
                    leaderboardList
                }
                .padding(18)
                .padding(.bottom, 24)
            }
        }
    }

    private var scoreSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Günün Puan Durumu")
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeButtonStart)

            HStack(spacing: 10) {
                summaryItem(icon: "star.fill", color: .yellow, value: "\(viewModel.totalScore)", title: "Toplam Puan")
                summaryItem(icon: "target", color: .red, value: "\(viewModel.correctGuessCount)", title: "Doğru Tahmin")
                summaryItem(icon: "gamecontroller.fill", color: Color.bizBizeButtonStart, value: "\(viewModel.gameParticipationCount)", title: "Oyun Katılımı")
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.bizBizeFieldBackground, Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 18, x: 0, y: 9)
    }

    private var leaderboardList: some View {
        VStack(spacing: 6) {
            if viewModel.entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.67, blue: 0.12))

                    Text("Henüz liderlik verisi yok.")
                        .font(.headline.bold())
                        .foregroundStyle(Color.bizBizeInk)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
            } else {
                ForEach(viewModel.entries) { entry in
                    LeaderboardRow(
                        entry: entry,
                        displayName: viewModel.displayName(for: entry)
                    )

                    if entry.id != viewModel.entries.last?.id {
                        Divider()
                            .background(Color.bizBizeBorder)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.07), radius: 16, x: 0, y: 8)
    }

    private func summaryItem(icon: String, color: Color, value: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)

            Text(value)
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeInk)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.bizBizeMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}
