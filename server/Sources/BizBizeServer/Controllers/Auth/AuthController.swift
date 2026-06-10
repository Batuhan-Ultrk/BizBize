import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("register", use: register)
        auth.post("login", use: login)
        auth.post("password-reset", use: requestPasswordReset)
        auth.post("password-reset", "confirm", use: confirmPasswordReset)

        let protected = auth.grouped(UserToken.authenticator())
        protected.post("logout", use: logout)
        protected.get("me", use: me)
    }

    @Sendable
    func register(req: Request) async throws -> AuthResponseDTO {
        try RegisterRequestDTO.validate(content: req)
        let payload = try req.content.decode(RegisterRequestDTO.self)
        let email = payload.email.normalizedEmail

        let existingUser = try await User.query(on: req.db)
            .filter(\.$email == email)
            .first()
        guard existingUser == nil else {
            throw Abort(.conflict, reason: "Bu e-posta adresi zaten kayıtlı.")
        }

        if let maxRegisteredUsers = Environment.get("MAX_REGISTERED_USERS").flatMap(Int.init) {
            let userCount = try await User.query(on: req.db).count()
            guard userCount < maxRegisteredUsers else {
                throw Abort(.insufficientStorage, reason: "Backend kullanıcı kotası dolu.")
            }
        }

        let user = try User(
            firstName: payload.firstName.trimmed,
            lastName: payload.lastName.trimmed,
            birthDate: payload.birthDate,
            phoneNumber: payload.phoneNumber.trimmed,
            email: email,
            passwordHash: Bcrypt.hash(payload.password)
        )
        try await user.save(on: req.db)

        let token = try await issueSingleToken(for: user, on: req.db)

        return try AuthResponseDTO(token: token.value, user: user.toPublicDTO())
    }

    @Sendable
    func login(req: Request) async throws -> AuthResponseDTO {
        try LoginRequestDTO.validate(content: req)
        let payload = try req.content.decode(LoginRequestDTO.self)
        let email = payload.email.normalizedEmail

        guard let user = try await User.query(on: req.db)
            .filter(\.$email == email)
            .first(),
            try user.verify(password: payload.password)
        else {
            throw Abort(.unauthorized, reason: "E-posta veya şifre hatalı.")
        }

        guard user.passwordResetRequired == false else {
            throw Abort(.forbidden, reason: "Logout sonrası tekrar giriş için şifre sıfırlama zorunludur.")
        }

        let token = try await issueSingleToken(for: user, on: req.db)

        return try AuthResponseDTO(token: token.value, user: user.toPublicDTO())
    }

    @Sendable
    func logout(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        try await UserToken.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .delete()

        user.passwordResetRequired = true
        try await user.save(on: req.db)

        return .noContent
    }

    @Sendable
    func me(req: Request) async throws -> PublicUserDTO {
        try req.auth.require(User.self).toPublicDTO()
    }

    @Sendable
    func requestPasswordReset(req: Request) async throws -> PasswordResetResponseDTO {
        try PasswordResetRequestDTO.validate(content: req)
        let payload = try req.content.decode(PasswordResetRequestDTO.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$email == payload.email.normalizedEmail)
            .first()
        else {
            return PasswordResetResponseDTO(message: "Şifre sıfırlama isteği işlendi.")
        }

        try await PasswordResetToken.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .delete()

        let resetToken = try PasswordResetToken.generate(for: user)
        try await resetToken.save(on: req.db)
        req.logger.info("Password reset token generated for \(user.email).")

        return PasswordResetResponseDTO(message: "Şifre sıfırlama isteği işlendi.")
    }

    @Sendable
    func confirmPasswordReset(req: Request) async throws -> HTTPStatus {
        try PasswordResetConfirmDTO.validate(content: req)
        let payload = try req.content.decode(PasswordResetConfirmDTO.self)

        guard let resetToken = try await PasswordResetToken.query(on: req.db)
            .filter(\.$value == payload.token)
            .with(\.$user)
            .first()
        else {
            throw Abort(.notFound, reason: "Şifre sıfırlama token'ı bulunamadı.")
        }

        guard resetToken.expiresAt > Date() else {
            try await resetToken.delete(on: req.db)
            throw Abort(.gone, reason: "Şifre sıfırlama token'ının süresi dolmuş.")
        }

        let user = resetToken.user
        user.passwordHash = try Bcrypt.hash(payload.newPassword)
        user.passwordResetRequired = false
        try await user.save(on: req.db)
        try await resetToken.delete(on: req.db)

        return .noContent
    }

    private func issueSingleToken(for user: User, on database: any Database) async throws -> UserToken {
        let userID = try user.requireID()
        try await UserToken.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()

        let token = try UserToken.generate(for: user)
        try await token.save(on: database)
        return token
    }
}
