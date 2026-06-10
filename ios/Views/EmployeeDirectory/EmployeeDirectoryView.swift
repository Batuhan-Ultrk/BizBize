import SwiftUI

struct EmployeeDirectoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EmployeeDirectoryViewModel

    init(viewModel: EmployeeDirectoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                searchSection
                content
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchEmployees()
        }
        .refreshable {
            await viewModel.fetchEmployees()
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

            Text("Çalışan Rehberi")
                .font(.headline.bold())
                .foregroundStyle(Color.bizBizeInk)

            Spacer()

            Button {
                Task {
                    await viewModel.clearFilters()
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.bizBizeInk)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var searchSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.bizBizeMuted)

                TextField("Çalışan ara...", text: $viewModel.searchText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await viewModel.fetchEmployees()
                        }
                    }

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        Task {
                            await viewModel.fetchEmployees()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.bizBizeMuted)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.bizBizeBorder, lineWidth: 1)
            )

            if !viewModel.departments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        departmentChip(title: "Tümü", department: nil)

                        ForEach(viewModel.departments, id: \.self) { department in
                            departmentChip(title: department, department: department)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.employees.isEmpty {
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Color.bizBizeButtonStart)

                Text("Çalışanlar yükleniyor...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.employees.isEmpty {
            VStack(spacing: 14) {
                HomeIconView(kind: .directory, size: 56)

                Text("Çalışan bulunamadı.")
                    .font(.headline.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Text("Arama veya departman filtresini değiştirerek tekrar dene.")
                    .font(.subheadline)
                    .foregroundStyle(Color.bizBizeMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.employees) { employee in
                        EmployeeDirectoryRow(employee: employee)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }

    private func departmentChip(title: String, department: String?) -> some View {
        Button {
            Task {
                viewModel.selectedDepartment = department
                await viewModel.fetchEmployees()
            }
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(viewModel.selectedDepartment == department ? .white : Color.bizBizeInk)
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(viewModel.selectedDepartment == department ? Color.bizBizeButtonStart : Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.bizBizeBorder, lineWidth: viewModel.selectedDepartment == department ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct EmployeeDirectoryRow: View {
    let employee: EmployeeDTO

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 5) {
                Text(employee.fullName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.bizBizeInk)
                    .lineLimit(1)

                Text(employee.department ?? "Departman belirtilmedi")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
                    .lineLimit(1)

                Text(employee.email)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.bizBizeMuted)
                    .lineLimit(1)

                if let phoneNumber = employee.phoneNumber, !phoneNumber.isEmpty {
                    EmployeeInfoLine(icon: "phone", text: phoneNumber)
                }

                EmployeeInfoLine(icon: "birthday.cake", text: employee.formattedBirthDate)
            }

            Spacer()

            VStack(spacing: 12) {
                if let mailURL = URL(string: "mailto:\(employee.email)") {
                    Link(destination: mailURL) {
                        Image(systemName: "envelope")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.bizBizeInk)
                    }
                }

                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.bizBizeMuted)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.bizBizePrimary.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    private var avatar: some View {
        ZStack {
            if let profilePhoto = employee.profilePhoto,
               let url = URL(string: profilePhoto) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    placeholderAvatar
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                placeholderAvatar
            }
        }
        .frame(width: 48, height: 48)
    }

    private var placeholderAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.bizBizeSecondary, Color.bizBizeButtonStart],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(employee.initials)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
    }
}

private struct EmployeeInfoLine: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.bizBizeButtonStart)
                .frame(width: 13)

            Text(text)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.bizBizeMuted)
                .lineLimit(1)
        }
    }
}
