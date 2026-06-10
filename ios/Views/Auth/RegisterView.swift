import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var viewModel: AuthViewModel

    let onLoginTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    labeledField(L10n.text("auth.register.firstName.label")) {
                        AuthTextField(
                            title: L10n.text("auth.register.firstName.placeholder"),
                            text: $viewModel.firstName,
                            systemImage: "person",
                            showsLeadingIcon: false,
                            errorMessage: viewModel.registerFirstNameError
                        )
                    }

                    labeledField(L10n.text("auth.register.lastName.label")) {
                        AuthTextField(
                            title: L10n.text("auth.register.lastName.placeholder"),
                            text: $viewModel.lastName,
                            systemImage: "person",
                            showsLeadingIcon: false,
                            errorMessage: viewModel.registerLastNameError
                        )
                    }
                }

                labeledField(L10n.text("auth.register.birthDate.label")) {
                    VStack(alignment: .leading, spacing: 6) {
                        DatePicker("", selection: birthDateBinding, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.bizBizeInk)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 56)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(viewModel.registerBirthDateError == nil ? Color.bizBizeBorder : .red.opacity(0.75), lineWidth: 1.2)
                            )

                        if let errorMessage = viewModel.registerBirthDateError {
                            Text(errorMessage)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                labeledField(L10n.text("auth.register.phone.label")) {
                    AuthTextField(
                        title: L10n.text("auth.register.phone.placeholder"),
                        text: $viewModel.phoneNumber,
                        systemImage: "phone",
                        keyboardType: .phonePad,
                        textContentType: .telephoneNumber,
                        showsLeadingIcon: false,
                        errorMessage: viewModel.registerPhoneNumberError
                    )
                }

                labeledField(L10n.text("auth.email.label")) {
                    AuthTextField(
                        title: L10n.text("auth.register.email.placeholder"),
                        text: $viewModel.email,
                        systemImage: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never,
                        showsLeadingIcon: false,
                        errorMessage: viewModel.registerEmailError
                    )
                }

                labeledField(L10n.text("auth.password.label")) {
                    AuthTextField(
                        title: L10n.text("auth.register.password.placeholder"),
                        text: $viewModel.password,
                        systemImage: "lock",
                        isSecure: true,
                        textContentType: .newPassword,
                        showsLeadingIcon: false,
                        errorMessage: viewModel.registerPasswordError
                    )
                }
            }

            PrimaryButton(
                title: L10n.text("auth.register.button"),
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.register()
                }
            }

            HStack(spacing: 6) {
                Text(L10n.text("auth.register.hasAccount"))
                    .foregroundStyle(Color.bizBizeMuted)

                Button(action: onLoginTap) {
                    Text(L10n.text("auth.register.loginLink"))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.bizBizeButtonStart)
                }
            }
            .font(.callout.weight(.semibold))
        }
        .padding(.top, 4)
        .alert(L10n.text("alert.error.title"), isPresented: $viewModel.showAlert) {
            Button(L10n.text("alert.ok"), role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .tint(Color.bizBizeButtonStart)
    }

    private var birthDateBinding: Binding<Date> {
        Binding {
            viewModel.birthDate
        } set: { newValue in
            viewModel.birthDate = newValue
            viewModel.didSelectBirthDate = true
            viewModel.registerBirthDateError = nil
        }
    }

    private func labeledField<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.bizBizeInk)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
