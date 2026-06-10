import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthViewModel

    let onRegisterTap: () -> Void
    let onForgotPasswordTap: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.text("auth.email.label"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)

                AuthTextField(
                    title: L10n.text("auth.email.placeholder"),
                    text: $viewModel.email,
                    systemImage: "envelope",
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .never,
                    showsLeadingIcon: false,
                    errorMessage: viewModel.loginEmailError
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.text("auth.password.label"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.bizBizeInk)

                AuthTextField(
                    title: L10n.text("auth.password.placeholder"),
                    text: $viewModel.password,
                    systemImage: "lock",
                    isSecure: true,
                    textContentType: .password,
                    showsLeadingIcon: false,
                    errorMessage: viewModel.loginPasswordError
                )
            }

            Button(action: onForgotPasswordTap) {
                Text(L10n.text("auth.forgotPassword.link"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.bizBizeButtonStart)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            PrimaryButton(
                title: L10n.text("auth.login.button"),
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.login()
                }
            }

            HStack(spacing: 6) {
                Text(L10n.text("auth.login.noAccount"))
                    .foregroundStyle(Color.bizBizeMuted)

                Button(action: onRegisterTap) {
                    Text(L10n.text("auth.register.button"))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.bizBizeButtonStart)
                }
            }
            .font(.callout.weight(.semibold))
        }
        .padding(.top, 8)
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
