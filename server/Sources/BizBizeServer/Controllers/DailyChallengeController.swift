import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct DailyChallengeController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let protected = routes
            .grouped(UserToken.authenticator())
            .grouped("challenges")

        protected.get("today", use: today)
        protected.post("today", "guess", use: guess)
    }

    @Sendable
    func today(req: Request) async throws -> ChallengeResponseDTO {
        let user = try req.auth.require(User.self)
        let now = Date()

        guard let challenge = try await DailyChallengeService.ensureToday(on: req.db, now: now) else {
            throw Abort(.notFound, reason: "Günün gizemli çalışanı henüz seçilmedi.")
        }

        return try await makeResponse(for: challenge, currentUser: user, on: req.db, now: now)
    }

    @Sendable
    func guess(req: Request) async throws -> ChallengeResponseDTO {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let now = Date()

        try SubmitGuessRequestDTO.validate(content: req)
        let payload = try req.content.decode(SubmitGuessRequestDTO.self)

        guard let challenge = try await DailyChallengeService.ensureToday(on: req.db, now: now) else {
            throw Abort(.notFound, reason: "Günün gizemli çalışanı henüz seçilmedi.")
        }

        _ = try await DailyChallengeService.submitGuess(
            userID: userID,
            guessedUserID: payload.guessedUserId,
            challenge: challenge,
            on: req.db
        )

        return try await makeResponse(for: challenge, currentUser: user, on: req.db, now: now)
    }

    private func makeResponse(
        for challenge: DailyChallenge,
        currentUser: User,
        on database: any Database,
        now: Date
    ) async throws -> ChallengeResponseDTO {
        let challengeID = try challenge.requireID()
        let currentUserID = try currentUser.requireID()

        try await challenge.$selectedUser.load(on: database)

        let elapsed = now.timeIntervalSince(challenge.createdAt ?? now)
        let hints = try await DailyChallengeService.getOrGenerateHints(for: challenge.selectedUser, on: database)
            .map { hint -> HintResponseDTO in
                let revealDelay = Double((hint.revealOrder - 1) * 3600)
                let isRevealed = elapsed >= revealDelay
                let secondsUntil = isRevealed ? nil : Int(revealDelay - elapsed)
                return HintResponseDTO(
                    id: try hint.requireID(),
                    type: hint.type,
                    revealOrder: hint.revealOrder,
                    text: isRevealed ? hint.text : nil,
                    isRevealed: isRevealed,
                    secondsUntilReveal: secondsUntil
                )
            }

        let candidates = try await User.query(on: database)
            .filter(\.$id ~~ challenge.candidateUserIds)
            .all()
        
        // Ensure candidates order matches the saved list
        var orderedCandidates: [PublicUserDTO] = []
        for id in challenge.candidateUserIds {
            if let candidate = candidates.first(where: { $0.id == id }) {
                try orderedCandidates.append(candidate.toPublicDTO())
            }
        }

        let myGuessRecord = try await Guess.query(on: database)
            .filter(\.$challenge.$id == challengeID)
            .filter(\.$user.$id == currentUserID)
            .first()

        let myGuess: GuessResponseDTO? = try myGuessRecord.map { gr in
            try GuessResponseDTO(
                id: gr.requireID(),
                guessedUserId: gr.$guessedUser.id,
                isCorrect: gr.isCorrect,
                isFirstCorrect: gr.isFirstCorrect,
                timestamp: gr.timestamp
            )
        }

        let todayKey = DailyChallengeService.makeDayKey(from: now)
        let isPastChallenge = challenge.dayKey < todayKey
        let guessedCorrectly = myGuessRecord?.isCorrect ?? false
        let revealIdentity = isPastChallenge || guessedCorrectly

        let revealedUser: PublicUserDTO? = revealIdentity ? try challenge.selectedUser.toPublicDTO() : nil

        return ChallengeResponseDTO(
            id: challengeID,
            dayKey: challenge.dayKey,
            hints: hints,
            candidates: orderedCandidates,
            isGuessed: myGuessRecord != nil,
            myGuess: myGuess,
            revealedUser: revealedUser
        )
    }
}
