import SwiftUI

struct MysteryEmployeeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MysteryEmployeeViewModel

    init(viewModel: MysteryEmployeeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            content
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchChallenge()
        }
        .refreshable {
            await viewModel.fetchChallenge()
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

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.challenge == nil {
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Color.bizBizeButtonStart)

                Text("Gizemli çalışan yükleniyor...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }
        } else if let challenge = viewModel.challenge {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    heroCard(challenge)

                    if let result = viewModel.guessResult {
                        resultCard(result)
                    }

                    hintsCard(challenge)
                    guessCard(challenge)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
        } else {
            VStack(spacing: 14) {
                HomeIconView(kind: .mysteryEmployee, size: 58)

                Text("Bugün için gizemli çalışan bulunamadı.")
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)
                    .multilineTextAlignment(.center)

                Button {
                    Task {
                        await viewModel.fetchChallenge()
                    }
                } label: {
                    Text("Tekrar Dene")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 44)
                        .background(Color.bizBizeButtonStart)
                        .clipShape(Capsule())
                }
            }
            .padding(28)
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Gizemli Çalışan")
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeInk)

            Spacer()

            Image(systemName: "questionmark.circle")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.bizBizeInk)
                .frame(width: 40, height: 40)
        }
        .padding(.top, 8)
        .padding(.horizontal, 2)
    }

    private func heroCard(_ challenge: MysteryChallengeDTO) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Oyun Başlıyor!")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Label(challenge.formattedExpiresAt, systemImage: "clock")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.88))

                    Text(challenge.question)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 88, height: 88)

                    HomeIconView(kind: .mysteryEmployee, size: 54)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.09, blue: 0.28),
                    Color(red: 0.18, green: 0.14, blue: 0.43),
                    Color.bizBizeButtonStart
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.16), radius: 18, x: 0, y: 10)
    }

    private func hintsCard(_ challenge: MysteryChallengeDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("İpuçları")
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Spacer()

                Text("\(challenge.hintCount)")
                    .font(.caption.bold())
                    .foregroundStyle(Color.bizBizeButtonStart)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.bizBizeFieldBackground)
                    .clipShape(Capsule())
            }

            hintRow(icon: "sparkles", text: "Bugünün gizemli çalışanı adaylar arasında.")
            hintRow(icon: "person.2.fill", text: "\(challenge.options.count) adaydan birini seç.")
            hintRow(icon: "clock.fill", text: "Süre bitmeden tahminini gönder.")
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.06), radius: 14, x: 0, y: 7)
    }

    private func guessCard(_ challenge: MysteryChallengeDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tahminini Yap")
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeButtonStart)

            Text("Gizemli çalışanın kim olduğunu tahmin et!")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.bizBizeMuted)

            Menu {
                ForEach(challenge.options, id: \.self) { option in
                    Button(option) {
                        viewModel.selectedOption = option
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedOption ?? "Kişi seçiniz...")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(viewModel.selectedOption == nil ? Color.bizBizeMuted : Color.bizBizeInk)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(Color.bizBizeMuted)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.bizBizeFieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Button {
                Task {
                    await viewModel.submitGuess()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.isSubmitting ? "Gönderiliyor..." : "Tahmin Et")
                        .font(.headline.bold())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: viewModel.canSubmit
                            ? [Color.bizBizeButtonStart, Color.bizBizeButtonEnd]
                            : [Color.bizBizeMuted.opacity(0.6), Color.bizBizeMuted.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(!viewModel.canSubmit)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.06), radius: 14, x: 0, y: 7)
    }

    private func resultCard(_ result: MysteryGuessResponseDTO) -> some View {
        HStack(spacing: 14) {
            Image(systemName: result.correct ? "party.popper.fill" : "xmark.circle.fill")
                .font(.title.bold())
                .foregroundStyle(result.correct ? Color.green : Color.red)

            VStack(alignment: .leading, spacing: 5) {
                Text(result.correct ? "Tebrikler!" : "Yanlış tahmin")
                    .font(.headline.bold())
                    .foregroundStyle(result.correct ? Color.green : Color.red)

                Text(result.correct ? "Doğru tahmin ile \(result.earnedPoints) puan kazandın." : "Yarın tekrar deneyebilirsin.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)

                if let badgeAwarded = result.badgeAwarded, !badgeAwarded.isEmpty {
                    Text("Rozet: \(badgeAwarded)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.bizBizeButtonStart)
                }
            }

            Spacer()

            if result.earnedPoints > 0 {
                Text("+\(result.earnedPoints)\nPuan")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 58, height: 58)
                    .background(Color.bizBizeButtonStart)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.08), radius: 16, x: 0, y: 8)
    }

    private func hintRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.bizBizeButtonStart)
                .frame(width: 18)

            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.bizBizeInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
