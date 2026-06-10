import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let protectedUsers = routes
            .grouped(UserToken.authenticator())
            .grouped("users")
        
        protectedUsers.get(use: index)
        protectedUsers.get(":userID", use: show)

        let protectedAuth = routes
            .grouped(UserToken.authenticator())
            .grouped("auth")

        protectedAuth.patch("me", use: updateProfile)
        protectedAuth.post("me", "hints", use: saveHints)
    }

    struct UserListQuery: Codable {
        let search: String?
        let sortBy: String?
    }

    @Sendable
    func index(req: Request) async throws -> [PublicUserDTO] {
        let query = try req.query.decode(UserListQuery.self)
        var builder = User.query(on: req.db)

        if let search = query.search?.trimmed, !search.isEmpty {
            builder = builder.group(.or) { group in
                group.filter(\.$firstName, .custom("ilike"), "%\(search)%")
                     .filter(\.$lastName, .custom("ilike"), "%\(search)%")
            }
        }

        if query.sortBy == "name" {
            builder = builder.sort(\.$firstName, .ascending).sort(\.$lastName, .ascending)
        } else {
            builder = builder.sort(\.$createdAt, .descending)
        }

        let users = try await builder.all()
        return try users.map { try $0.toPublicDTO() }
    }

    @Sendable
    func show(req: Request) async throws -> UserDetailResponseDTO {
        let currentUser = try req.auth.require(User.self)
        let currentUserID = try currentUser.requireID()

        guard
            let userID = req.parameters.get("userID", as: UUID.self),
            let user = try await User.find(userID, on: req.db)
        else {
            throw Abort(.notFound, reason: "Kullanıcı bulunamadı.")
        }

        let score = try await UserScore.query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()

        let badges = try await Badge.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$earnedAt, .descending)
            .all()
            .map { badge in
                try BadgeResponseDTO(
                    id: badge.requireID(),
                    type: badge.type,
                    earnedAt: badge.earnedAt,
                    periodLabel: badge.periodLabel
                )
            }

        let isSelf = (userID == currentUserID)

        let scoreHistory: [ScoreEventResponseDTO]? = isSelf ? try await ScoreEvent.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$createdAt, .descending)
            .all()
            .map { event in
                try ScoreEventResponseDTO(
                    id: event.requireID(),
                    points: event.points,
                    type: event.type,
                    createdAt: event.createdAt ?? Date()
                )
            } : nil

        let hints: [HintItemDTO]? = isSelf ? try await Hint.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$revealOrder, .ascending)
            .all()
            .map { hint in
                HintItemDTO(type: hint.type, text: hint.text, revealOrder: hint.revealOrder)
            } : nil

        return UserDetailResponseDTO(
            id: userID,
            firstName: user.firstName,
            lastName: user.lastName,
            birthDate: user.birthDate,
            phoneNumber: user.phoneNumber,
            email: user.email,
            department: user.department,
            startDate: user.startDate,
            profilePhoto: user.profilePhoto,
            createdAt: user.createdAt,
            weeklyPoints: score?.weeklyPoints ?? 0,
            totalPoints: score?.totalPoints ?? 0,
            badges: badges,
            scoreHistory: scoreHistory,
            hints: hints
        )
    }

    @Sendable
    func updateProfile(req: Request) async throws -> PublicUserDTO {
        let user = try req.auth.require(User.self)
        try UpdateProfileRequestDTO.validate(content: req)
        let payload = try req.content.decode(UpdateProfileRequestDTO.self)

        if let dept = payload.department {
            user.department = dept.trimmed.isEmpty ? nil : dept.trimmed
        }
        if let startDate = payload.startDate {
            user.startDate = startDate
        }
        if let photo = payload.profilePhoto {
            user.profilePhoto = photo.trimmed.isEmpty ? nil : photo.trimmed
        }

        try await user.save(on: req.db)
        return try user.toPublicDTO()
    }

    @Sendable
    func saveHints(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        try SaveHintsRequestDTO.validate(content: req)
        let payload = try req.content.decode(SaveHintsRequestDTO.self)

        // Validate that each revealOrder is unique and within 1...payload.hints.count
        let orders = payload.hints.map(\.revealOrder)
        guard Set(orders).count == orders.count else {
            throw Abort(.badRequest, reason: "İpucu sıralamaları (revealOrder) tekrarlı olamaz.")
        }
        
        let validTypes = Set(HintType.allCases.map(\.rawValue))
        for hint in payload.hints {
            guard validTypes.contains(hint.type) else {
                throw Abort(.badRequest, reason: "Geçersiz ipucu türü: \(hint.type)")
            }
        }

        // Delete existing hints
        try await Hint.query(on: req.db)
            .filter(\.$user.$id == userID)
            .delete()

        // Save new hints
        for hintDTO in payload.hints {
            let hint = Hint(
                userID: userID,
                type: hintDTO.type,
                text: hintDTO.text.trimmed,
                revealOrder: hintDTO.revealOrder
            )
            try await hint.save(on: req.db)
        }

        return .noContent
    }
}
