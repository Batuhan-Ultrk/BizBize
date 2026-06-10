import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct PollController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let polls = routes
            .grouped(UserToken.authenticator())
            .grouped("polls")

        polls.get(use: index)
        polls.post(use: create)

        polls.group("daily-lunch") { dailyLunch in
            dailyLunch.get(use: self.dailyLunch)
            dailyLunch.post("vote", use: voteDailyLunch)
        }

        polls.group(":pollID") { poll in
            poll.get(use: show)
            poll.post("vote", use: vote)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [PollResponseDTO] {
        _ = try await DailyLunchPollService.ensureToday(on: req.db)

        let user = try req.auth.require(User.self)
        let query = try req.query.decode(PollListQueryDTO.self)
        var builder = Poll.query(on: req.db)

        if let type = query.type {
            builder = builder.filter(\.$type == type)
        }

        let polls = try await builder
            .sort(\.$createdAt, .descending)
            .all()
            .filter { poll in
                poll.isVisible(to: user)
            }

        var responses: [PollResponseDTO] = []
        for poll in polls {
            let response = try await makeResponse(for: poll, currentUser: user, on: req.db)
            responses.append(response)
        }
        return responses
    }

    @Sendable
    func create(req: Request) async throws -> PollResponseDTO {
        let user = try req.auth.require(User.self)
        try CreatePollRequestDTO.validate(content: req)
        let payload = try req.content.decode(CreatePollRequestDTO.self)

        let optionTexts = payload.options.map(\.trimmed).filter { !$0.isEmpty }
        guard optionTexts.count == payload.options.count else {
            throw Abort(.badRequest, reason: "Anket seçenekleri boş olamaz.")
        }
        guard Set(optionTexts).count == optionTexts.count else {
            throw Abort(.badRequest, reason: "Anket seçenekleri tekrarlı olamaz.")
        }

        let targetUserIds = try await validateTargetUsers(payload.targetUserIds ?? [], on: req.db)
        let poll = try Poll(
            createdByUserID: user.requireID(),
            type: .manual,
            question: payload.question.trimmed,
            expiresAt: payload.expiresAt,
            targetUserIds: targetUserIds
        )
        try await poll.save(on: req.db)

        for (index, optionText) in optionTexts.enumerated() {
            let option = try PollOption(
                pollID: poll.requireID(),
                text: optionText,
                displayOrder: index
            )
            try await option.save(on: req.db)
        }

        try await ScoreService.awardPoints(
            userID: user.requireID(),
            points: 0,
            type: "pollCreate",
            sourceID: poll.requireID(),
            engagementPoints: 2,
            on: req.db
        )

        return try await makeResponse(for: poll, currentUser: user, on: req.db)
    }

    @Sendable
    func show(req: Request) async throws -> PollResponseDTO {
        let user = try req.auth.require(User.self)
        let poll = try await findVisiblePoll(req: req, for: user)
        return try await makeResponse(for: poll, currentUser: user, on: req.db)
    }

    @Sendable
    func vote(req: Request) async throws -> PollResponseDTO {
        let user = try req.auth.require(User.self)
        let poll = try await findVisiblePoll(req: req, for: user)
        try VotePollRequestDTO.validate(content: req)
        let payload = try req.content.decode(VotePollRequestDTO.self)

        try await castVote(poll: poll, optionID: payload.optionId, user: user, on: req.db)
        try await ScoreService.awardPoints(
            userID: user.requireID(),
            points: 10,
            type: "pollVote",
            sourceID: poll.requireID(),
            engagementPoints: 1,
            on: req.db
        )
        return try await makeResponse(for: poll, currentUser: user, on: req.db)
    }

    @Sendable
    func dailyLunch(req: Request) async throws -> PollResponseDTO {
        let user = try req.auth.require(User.self)
        guard let poll = try await DailyLunchPollService.ensureToday(on: req.db) else {
            throw Abort(.notFound, reason: "Günün yemek anketi henüz açılmadı.")
        }
        return try await makeResponse(for: poll, currentUser: user, on: req.db)
    }

    @Sendable
    func voteDailyLunch(req: Request) async throws -> PollResponseDTO {
        let user = try req.auth.require(User.self)
        try VoteDailyLunchPollRequestDTO.validate(content: req)
        let payload = try req.content.decode(VoteDailyLunchPollRequestDTO.self)

        guard let poll = try await DailyLunchPollService.ensureToday(on: req.db) else {
            throw Abort(.notFound, reason: "Günün yemek anketi henüz açılmadı.")
        }

        let dailyLunchOptions = try await PollOption.query(on: req.db)
            .filter(\.$poll.$id == poll.requireID())
            .all()
        guard let option = dailyLunchOptions.first(where: { $0.key == payload.option.rawValue }) else {
            throw Abort(.notFound, reason: "Yemek anketi seçeneği bulunamadı.")
        }

        try await castVote(poll: poll, optionID: option.requireID(), user: user, on: req.db)
        try await ScoreService.awardPoints(
            userID: user.requireID(),
            points: 10,
            type: "pollVote",
            sourceID: poll.requireID(),
            engagementPoints: 1,
            on: req.db
        )
        return try await makeResponse(for: poll, currentUser: user, on: req.db)
    }

    private func findVisiblePoll(req: Request, for user: User) async throws -> Poll {
        guard
            let pollID = req.parameters.get("pollID", as: UUID.self),
            let poll = try await Poll.find(pollID, on: req.db)
        else {
            throw Abort(.notFound)
        }

        guard poll.isVisible(to: user) else {
            throw Abort(.notFound)
        }

        return poll
    }

    private func castVote(poll: Poll, optionID: UUID, user: User, on database: any Database) async throws {
        guard poll.isClosed == false else {
            throw Abort(.badRequest, reason: "Anket kapandı.")
        }

        guard let option = try await PollOption.find(optionID, on: database), option.$poll.id == (try poll.requireID()) else {
            throw Abort(.badRequest, reason: "Geçersiz anket seçeneği.")
        }

        let existingVote = try await PollVote.query(on: database)
            .filter(\.$poll.$id == poll.requireID())
            .filter(\.$user.$id == user.requireID())
            .first()
        guard existingVote == nil else {
            throw Abort(.conflict, reason: "Bu ankete daha önce oy verdiniz.")
        }

        let vote = try PollVote(
            pollID: poll.requireID(),
            optionID: option.requireID(),
            userID: user.requireID()
        )
        try await vote.save(on: database)
    }

    private func makeResponse(for poll: Poll, currentUser: User, on database: any Database) async throws -> PollResponseDTO {
        let pollID = try poll.requireID()
        let options = try await PollOption.query(on: database)
            .filter(\.$poll.$id == pollID)
            .sort(\.$displayOrder, .ascending)
            .all()
        let votes = try await PollVote.query(on: database)
            .filter(\.$poll.$id == pollID)
            .all()
        let voteCounts = Dictionary(grouping: votes, by: { $0.$option.id })
            .mapValues(\.count)
        let currentUserID = try currentUser.requireID()
        let myVote = votes.first { vote in
            vote.$user.id == currentUserID
        }

        return PollResponseDTO(
            id: pollID,
            createdByUserId: poll.$createdByUser.id,
            type: poll.type,
            question: poll.question,
            options: try options.map { option in
                let optionID = try option.requireID()
                return PollOptionResponseDTO(
                    id: optionID,
                    text: option.text,
                    key: option.key,
                    displayOrder: option.displayOrder,
                    voteCount: voteCounts[optionID] ?? 0
                )
            },
            expiresAt: poll.expiresAt,
            targetUserIds: poll.targetUserIds,
            dayKey: poll.dayKey,
            isClosed: poll.isClosed,
            myVoteOptionId: myVote?.$option.id,
            createdAt: poll.createdAt
        )
    }

    private func validateTargetUsers(_ userIds: [UUID], on database: any Database) async throws -> [UUID] {
        let uniqueIds = Array(Set(userIds))
        guard uniqueIds.isEmpty == false else {
            return []
        }

        let foundCount = try await User.query(on: database)
            .filter(\.$id ~~ uniqueIds)
            .count()
        guard foundCount == uniqueIds.count else {
            throw Abort(.badRequest, reason: "Hedef kullanıcı listesinde geçersiz kullanıcı var.")
        }

        return uniqueIds
    }
}

private extension Poll {
    var isClosed: Bool {
        guard let expiresAt else {
            return false
        }

        return expiresAt <= Date()
    }

    func isVisible(to user: User) -> Bool {
        guard targetUserIds.isEmpty == false else {
            return true
        }

        guard let userID = user.id else {
            return false
        }

        return targetUserIds.contains(userID) || $createdByUser.id == userID
    }
}
