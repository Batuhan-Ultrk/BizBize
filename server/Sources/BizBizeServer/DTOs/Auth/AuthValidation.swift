import Vapor

extension RegisterRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: !.empty)
        validations.add("lastName", as: String.self, is: !.empty)
        validations.add("phoneNumber", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension LoginRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}

extension PasswordResetRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}

extension PasswordResetConfirmDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("token", as: String.self, is: !.empty)
        validations.add("newPassword", as: String.self, is: .count(8...))
    }
}
