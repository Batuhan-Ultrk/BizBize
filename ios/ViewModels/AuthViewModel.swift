import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = "" {
        didSet {
            loginEmailError = nil
            registerEmailError = nil
        }
    }
    @Published var password = "" {
        didSet {
            loginPasswordError = nil
            registerPasswordError = nil
        }
    }
    @Published var firstName = "" {
        didSet { registerFirstNameError = nil }
    }
    @Published var lastName = "" {
        didSet { registerLastNameError = nil }
    }
    @Published var birthDate = AuthViewModel.defaultBirthDate
    @Published var didSelectBirthDate = false {
        didSet {
            if didSelectBirthDate {
                registerBirthDateError = nil
            }
        }
    }
    @Published var phoneNumber = "" {
        didSet { registerPhoneNumberError = nil }
    }

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var loginEmailError: String?
    @Published var loginPasswordError: String?
    @Published var registerFirstNameError: String?
    @Published var registerLastNameError: String?
    @Published var registerBirthDateError: String?
    @Published var registerPhoneNumberError: String?
    @Published var registerEmailError: String?
    @Published var registerPasswordError: String?

    private let authService: AuthServiceProtocol
    private let appSession: AppSession

    init(
        authService: AuthServiceProtocol,
        appSession: AppSession
    ) {
        self.authService = authService
        self.appSession = appSession
    }

    func login() async {
        guard validateLogin() else { return }

        await performAuthRequest {
            let response = try await authService.login(
                request: LoginRequestDTO(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            )
            appSession.setSession(authResponse: response)
            resetRegisterForm()
            password = ""
        }
    }

    func register() async {
        guard validateRegistration() else { return }

        await performAuthRequest {
            let response = try await authService.register(
                request: RegisterRequestDTO(
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    birthDate: birthDate,
                    phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            )
            appSession.setSession(authResponse: response)
            resetRegisterForm()
        }
    }

    func requestPasswordReset() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = L10n.text("validation.email.required")
            return
        }

        await performRequest {
            let response = try await authService.requestPasswordReset(
                request: PasswordResetRequestDTO(email: trimmedEmail)
            )
            infoMessage = response.message
        }
    }

    func logout() {
        appSession.clearSession()
        password = ""
        errorMessage = nil
        infoMessage = nil
        alertMessage = nil
        showAlert = false
        clearFieldErrors()
    }

    func resetRegisterForm() {
        firstName = ""
        lastName = ""
        birthDate = Self.defaultBirthDate
        didSelectBirthDate = false
        phoneNumber = ""
        email = ""
        password = ""
        errorMessage = nil
        infoMessage = nil
        alertMessage = nil
        showAlert = false
        clearFieldErrors()
    }

    private func performAuthRequest(_ operation: () async throws -> Void) async {
        await performRequest(operation)
    }

    private func performRequest(_ operation: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        alertMessage = nil
        showAlert = false

        do {
            try await operation()
        } catch {
            let message = userFacingMessage(for: error)
            errorMessage = message
            alertMessage = message
            showAlert = true
        }

        isLoading = false
    }

    private func validateLogin() -> Bool {
        clearLoginErrors()
        errorMessage = nil
        infoMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        var isValid = true

        if trimmedEmail.isEmpty {
            loginEmailError = L10n.text("validation.email.required")
            isValid = false
        } else if !isValidEmail(trimmedEmail) {
            loginEmailError = L10n.text("validation.email.invalid")
            isValid = false
        }

        if password.isEmpty {
            loginPasswordError = L10n.text("validation.password.required")
            isValid = false
        }

        return isValid
    }

    private func validateRegistration() -> Bool {
        clearRegisterErrors()
        errorMessage = nil
        infoMessage = nil

        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        var isValid = true

        if trimmedFirstName.isEmpty {
            registerFirstNameError = L10n.text("validation.firstName.required")
            isValid = false
        }

        if trimmedLastName.isEmpty {
            registerLastNameError = L10n.text("validation.lastName.required")
            isValid = false
        }

        if !didSelectBirthDate {
            registerBirthDateError = L10n.text("validation.birthDate.required")
            isValid = false
        }

        if trimmedPhone.isEmpty {
            registerPhoneNumberError = L10n.text("validation.phone.required")
            isValid = false
        }

        if trimmedEmail.isEmpty {
            registerEmailError = L10n.text("validation.email.required")
            isValid = false
        } else if !isValidEmail(trimmedEmail) {
            registerEmailError = L10n.text("validation.email.invalid")
            isValid = false
        }

        if password.isEmpty {
            registerPasswordError = L10n.text("validation.password.required")
            isValid = false
        } else if password.count < 8 {
            registerPasswordError = L10n.text("validation.password.tooShort")
            isValid = false
        }

        return isValid
    }

    private func userFacingMessage(for error: Error) -> String {
        if let authError = error as? AuthServiceError {
            return authError.localizedDescription
        }

        return error.localizedDescription
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private static var defaultBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    }

    private func clearLoginErrors() {
        loginEmailError = nil
        loginPasswordError = nil
    }

    private func clearRegisterErrors() {
        registerFirstNameError = nil
        registerLastNameError = nil
        registerBirthDateError = nil
        registerPhoneNumberError = nil
        registerEmailError = nil
        registerPasswordError = nil
    }

    private func clearFieldErrors() {
        clearLoginErrors()
        clearRegisterErrors()
    }
}
