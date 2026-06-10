import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: ProfileViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bizBizeScreenBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        profileHeader
                        infoSection
                        statsSection
                        hintsSection
                        workModeSection
                        logoutButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await viewModel.fetchProfile()
                }
            }
            .navigationTitle("Profilim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color.bizBizeInk)
                    }
                }
            }
            .task {
                await viewModel.fetchProfile()
            }
            .alert("Hata", isPresented: $viewModel.showAlert) {
                Button("Tamam", role: .cancel) {
                    viewModel.alertMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .alert("Başarılı", isPresented: $viewModel.showSuccessAlert) {
                Button("Tamam", role: .cancel) {
                    viewModel.successMessage = nil
                }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .tint(Color.bizBizeButtonStart)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            avatar

            VStack(spacing: 5) {
                Text(viewModel.displayName)
                    .font(.title3.bold())
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(viewModel.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizePrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.bizBizeButtonStart, Color.bizBizeSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 96, height: 96)

            if let profilePhoto = viewModel.user?.profilePhoto,
               let url = URL(string: profilePhoto) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    initials
                }
                .frame(width: 86, height: 86)
                .clipShape(Circle())
            } else {
                initials
                    .frame(width: 86, height: 86)
                    .background(Color.bizBizeFieldBackground)
                    .clipShape(Circle())
            }
        }
    }

    private var initials: some View {
        Text(profileInitials)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(Color.bizBizeButtonStart)
    }

    private var infoSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                profileInfoCard(icon: "envelope", title: "E-posta", value: viewModel.email)
                profileInfoCard(icon: "phone", title: "Telefon", value: viewModel.phoneNumber)
            }

            HStack(spacing: 10) {
                profileInfoCard(icon: "calendar", title: "Doğum Tarihi", value: viewModel.birthDate)
                profileInfoCard(icon: "building.2", title: "Departman", value: viewModel.department)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 10) {
            profileStatCard(icon: "trophy.fill", color: .orange, value: "\(viewModel.correctGuessCount)", title: "Doğru Tahmin")
            profileStatCard(icon: "chart.bar.fill", color: Color.bizBizeButtonStart, value: "\(viewModel.pollParticipationCount)", title: "Anket Katılımı")
            profileStatCard(icon: "megaphone.fill", color: .red, value: "\(viewModel.announcementCount)", title: "Duyuru")
        }
    }

    private var workModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Çalışma Modum")
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Text("Bugün nerede çalışıyorsun?")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }

            HStack(spacing: 10) {
                ForEach(WorkMode.allCases) { mode in
                    Button {
                        viewModel.selectedWorkMode = mode
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: mode.icon)
                                .font(.title3.weight(.bold))

                            Text(mode.title)
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(viewModel.selectedWorkMode == mode ? Color.bizBizeButtonStart : Color.bizBizeInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 78)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(viewModel.selectedWorkMode == mode ? Color.bizBizeButtonStart : Color.bizBizeBorder, lineWidth: 1.4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hintsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Gizemli Çalışan İpuçlarım")
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Text("Kendinle ilgili 3 ila 5 ipucu gir.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }

            VStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    hintEditor(index: index)
                }
            }

            if let message = viewModel.hintValidationMessage {
                Text(message)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await viewModel.saveHints()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSavingHints {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.isSavingHints ? "Kaydediliyor..." : "İpuçlarını Kaydet")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: [Color.bizBizeButtonStart, Color.bizBizeButtonEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(viewModel.isSavingHints)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.06), radius: 14, x: 0, y: 7)
    }

    private var logoutButton: some View {
        Button {
            authViewModel.logout()
        } label: {
            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.bizBizePrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.bizBizeFieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func profileInfoCard(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.bizBizePrimary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)

                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private func hintEditor(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text("\(index + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.bizBizeButtonStart)
                    .clipShape(Circle())

                Menu {
                    ForEach(ProfileHintType.allCases) { type in
                        Button(type.title) {
                            viewModel.hintTypes[index] = type
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.hintTypes[index].title)
                            .font(.caption.weight(.bold))

                        Image(systemName: "chevron.down")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(Color.bizBizeButtonStart)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.bizBizeFieldBackground)
                    .clipShape(Capsule())
                }

                Spacer()
            }

            TextField("İpucunu yaz", text: $viewModel.hintTexts[index], axis: .vertical)
                .font(.subheadline.weight(.medium))
                .lineLimit(1...3)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.bizBizeFieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onChange(of: viewModel.hintTexts[index]) { _, _ in
                    viewModel.clearHintValidation()
                }
        }
    }

    private func profileStatCard(icon: String, color: Color, value: String, title: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)

            Text(value)
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeInk)

            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.bizBizeMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.bizBizeBorder.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: Color.bizBizePrimary.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var profileInitials: String {
        guard let user = viewModel.user else {
            return L10n.text("app.logo.initials")
        }

        let first = user.firstName.first.map(String.init) ?? ""
        let last = user.lastName.first.map(String.init) ?? ""
        return "\(first)\(last)".uppercased()
    }
}
