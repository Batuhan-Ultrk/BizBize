import Fluent
import Vapor
import struct Foundation.UUID

struct AnnouncementController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let announcements = routes
            .grouped(UserToken.authenticator())
            .grouped("announcements")

        announcements.get(use: index)
        announcements.post(use: create)
        announcements.group(":announcementID") { announcement in
            announcement.get(use: show)
            announcement.post("rsvp", use: rsvp)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [AnnouncementResponseDTO] {
        let user = try req.auth.require(User.self)
        let query = try req.query.decode(AnnouncementListQueryDTO.self)
        var builder = Announcement.query(on: req.db)

        if let type = query.type {
            builder = builder.filter(\.$type == type)
        }

        let announcements = try await builder
            .sort(\.$createdAt, .descending)
            .all()
            .filter { announcement in
                announcement.isVisible(to: user)
            }

        return try await announcements.asyncMap { announcement in
            try await makeResponse(for: announcement, currentUser: user, on: req.db)
        }
    }

    @Sendable
    func create(req: Request) async throws -> AnnouncementResponseDTO {
        let user = try req.auth.require(User.self)
        try CreateAnnouncementRequestDTO.validate(content: req)
        let payload = try req.content.decode(CreateAnnouncementRequestDTO.self)

        let targetUserIds = try await validateTargetUsers(payload.targetUserIds ?? [], on: req.db)
        let hasRsvp = payload.hasRsvp ?? payload.type.supportsRsvp
        guard payload.type.supportsRsvp || hasRsvp == false else {
            throw Abort(.badRequest, reason: "Katılım butonu yalnızca hediye ve etkinlik duyurularında kullanılabilir.")
        }

        let announcement = try Announcement(
            createdByUserID: user.requireID(),
            type: payload.type,
            title: payload.title.trimmed,
            body: payload.body.trimmed,
            eventDate: payload.eventDate,
            hasRsvp: hasRsvp,
            targetUserIds: targetUserIds
        )
        try await announcement.save(on: req.db)

        try await ScoreService.awardPoints(
            userID: user.requireID(),
            points: 0,
            type: "announcementCreate",
            sourceID: announcement.requireID(),
            engagementPoints: 2,
            on: req.db
        )

        return try await makeResponse(for: announcement, currentUser: user, on: req.db)
    }

    @Sendable
    func show(req: Request) async throws -> AnnouncementResponseDTO {
        let user = try req.auth.require(User.self)
        let announcement = try await findVisibleAnnouncement(req: req, for: user)
        
        try await ScoreService.awardPoints(
            userID: user.requireID(),
            points: 5,
            type: "announcementRead",
            sourceID: announcement.requireID(),
            engagementPoints: 1,
            on: req.db
        )

        return try await makeResponse(for: announcement, currentUser: user, on: req.db)
    }

    @Sendable
    func rsvp(req: Request) async throws -> AnnouncementResponseDTO {
        let user = try req.auth.require(User.self)
        let announcement = try await findVisibleAnnouncement(req: req, for: user)
        guard announcement.hasRsvp else {
            throw Abort(.badRequest, reason: "Bu duyuruda katılım seçeneği yok.")
        }

        try RSVPAnnouncementRequestDTO.validate(content: req)
        let payload = try req.content.decode(RSVPAnnouncementRequestDTO.self)
        let announcementID = try announcement.requireID()
        let userID = try user.requireID()

        if let existing = try await AnnouncementRSVP.query(on: req.db)
            .filter(\.$announcement.$id == announcementID)
            .filter(\.$user.$id == userID)
            .first()
        {
            existing.status = payload.status
            try await existing.save(on: req.db)
        } else {
            let rsvp = AnnouncementRSVP(
                announcementID: announcementID,
                userID: userID,
                status: payload.status
            )
            try await rsvp.save(on: req.db)
        }

        try await ScoreService.awardPoints(
            userID: userID,
            points: 0,
            type: "announcementRsvp",
            sourceID: announcementID,
            engagementPoints: 2,
            on: req.db
        )

        if payload.status == .attending && announcement.type == .event {
            try await ScoreService.awardPoints(
                userID: userID,
                points: 30,
                type: "eventAttendance",
                sourceID: announcementID,
                on: req.db
            )
        }

        return try await makeResponse(for: announcement, currentUser: user, on: req.db)
    }

    private func findVisibleAnnouncement(req: Request, for user: User) async throws -> Announcement {
        guard
            let announcementID = req.parameters.get("announcementID", as: UUID.self),
            let announcement = try await Announcement.find(announcementID, on: req.db)
        else {
            throw Abort(.notFound)
        }

        guard announcement.isVisible(to: user) else {
            throw Abort(.notFound)
        }

        return announcement
    }

    private func makeResponse(for announcement: Announcement, currentUser: User, on database: any Database) async throws -> AnnouncementResponseDTO {
        let announcementID = try announcement.requireID()
        let currentUserID = try currentUser.requireID()
        let rsvps = try await AnnouncementRSVP.query(on: database)
            .filter(\.$announcement.$id == announcementID)
            .all()

        let creatorUserID = announcement.$createdByUser.id
        let attendees = rsvps.compactMap { rsvp in
            rsvp.status == .attending ? rsvp.$user.id : nil
        }

        return AnnouncementResponseDTO(
            id: announcementID,
            createdByUserId: creatorUserID,
            type: announcement.type,
            title: announcement.title,
            body: announcement.body,
            eventDate: announcement.eventDate,
            hasRsvp: announcement.hasRsvp,
            targetUserIds: announcement.targetUserIds,
            attendees: creatorUserID == currentUserID ? attendees : [],
            myRsvpStatus: rsvps.first { rsvp in
                rsvp.$user.id == currentUserID
            }?.status,
            createdAt: announcement.createdAt
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

private extension Announcement {
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

private extension AnnouncementType {
    var supportsRsvp: Bool {
        self == .gift || self == .event
    }
}

private extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async throws -> [T] {
        var values: [T] = []
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}
