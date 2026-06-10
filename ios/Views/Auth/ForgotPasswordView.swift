import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var viewModel: AuthViewModel

    let onBackToLoginTap: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.text("auth.forgot.title"))
                    .font(.title2.bold())
                    .foregroundStyle(Color.bizBizeInk)

                Text(L10n.text("auth.forgot.description"))
                    .font(.subheadline)
                    .foregroundStyle(Color.bizBizeMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AuthTextField(
                title: L10n.text("auth.email.label"),
                text: $viewModel.email,
                systemImage: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )

            if let message = viewModel.infoMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(Color.bizBizePrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let errorMessage = viewModel.errorMessage, !viewModel.showAlert {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(
                title: L10n.text("auth.forgot.submit"),
                systemImage: "paperplane.fill",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.requestPasswordReset()
                }
            }

            Button(action: onBackToLoginTap) {
                Label(L10n.text("auth.forgot.backToLogin"), systemImage: "chevron.left")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.bizBizePrimary)
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 22, x: 0, y: 12)
        .alert(L10n.text("alert.error.title"), isPresented: $viewModel.showAlert) {
            Button(L10n.text("alert.ok"), role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .tint(Color.bizBizeButtonStart)
    }
}
