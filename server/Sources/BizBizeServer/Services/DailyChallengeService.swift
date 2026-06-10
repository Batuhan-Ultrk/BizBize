import Fluent
import Vapor
import Foundation

struct DailyChallengeService {
    static func ensureToday(on database: any Database, now: Date = Date()) async throws -> DailyChallenge? {
        let dayKey = makeDayKey(from: now)
        if let existing = try await DailyChallenge.query(on: database)
            .filter(\.$dayKey == dayKey)
            .first()
        {
            return existing
        }

        // Try to select a mystery employee
        do {
            let selectedUser = try await selectMysteryEmployee(on: database)
            let selectedUserID = try selectedUser.requireID()
            let candidateUserIds = try await generateCandidateUserIds(correctUserID: selectedUserID, on: database)

            let challenge = DailyChallenge(
                dayKey: dayKey,
                selectedUserID: selectedUserID,
                candidateUserIds: candidateUserIds
            )
            try await challenge.save(on: database)
            return challenge
        } catch {
            // If there are no users, we can't create a challenge
            return nil
        }
    }

    static func submitGuess(
        userID: UUID,
        guessedUserID: UUID,
        challenge: DailyChallenge,
        on database: any Database
    ) async throws -> Guess {
        let challengeID = try challenge.requireID()

        // Check if day matches today (no guessing past challenges)
        let todayKey = makeDayKey(from: Date())
        guard challenge.dayKey == todayKey else {
            throw Abort(.badRequest, reason: "Geçmiş günlerin tahminleri yapılamaz.")
        }

        // Check if user already guessed
        let existing = try await Guess.query(on: database)
            .filter(\.$challenge.$id == challengeID)
            .filter(\.$user.$id == userID)
            .first()
        guard existing == nil else {
            throw Abort(.badRequest, reason: "Bugünkü tahmininizi kullandınız.")
        }

        let isCorrect = (challenge.$selectedUser.id == guessedUserID)
        var isFirstCorrect = false

        if isCorrect {
            let correctCount = try await Guess.query(on: database)
                .filter(\.$challenge.$id == challengeID)
                .filter(\.$isCorrect == true)
                .count()
            isFirstCorrect = (correctCount == 0)

            let points = isFirstCorrect ? 150 : 100
            let scoreType = isFirstCorrect ? "firstCorrectGuess" : "correctGuess"

            try await ScoreService.awardPoints(
                userID: userID,
                points: points,
                type: scoreType,
                sourceID: challengeID,
                on: database
            )
        }

        let guess = Guess(
            challengeID: challengeID,
            userID: userID,
            guessedUserID: guessedUserID,
            isCorrect: isCorrect,
            isFirstCorrect: isFirstCorrect,
            timestamp: Date()
        )
        try await guess.save(on: database)

        return guess
    }

    static func selectMysteryEmployee(on db: any Database) async throws -> User {
        let allUsers = try await User.query(on: db).all()
        guard !allUsers.isEmpty else {
            throw Abort(.notFound, reason: "Sistemde kayıtlı kullanıcı bulunamadı.")
        }

        var candidateIds = try await DailyChallengeCandidate.query(on: db).all().map(\.$user.id)

        if candidateIds.isEmpty {
            // Reset cycle: insert all user IDs
            for user in allUsers {
                let userId = try user.requireID()
                let candidate = DailyChallengeCandidate(userID: userId)
                try await candidate.save(on: db)
            }
            candidateIds = try allUsers.map { try $0.requireID() }
        }

        let selectedId = candidateIds.randomElement()!

        // Remove from candidate pool
        if let candidateRecord = try await DailyChallengeCandidate.query(on: db)
            .filter(\.$user.$id == selectedId)
            .first() {
            try await candidateRecord.delete(on: db)
        }

        return allUsers.first(where: { $0.id == selectedId })!
    }

    static func generateCandidateUserIds(correctUserID: UUID, on db: any Database) async throws -> [UUID] {
        let allUsers = try await User.query(on: db).all()
        let otherUserIds = allUsers.compactMap { user -> UUID? in
            guard let id = user.id, id != correctUserID else { return nil }
            return id
        }

        var selectedIds = [correctUserID]
        let neededDistractors = min(3, otherUserIds.count)
        if neededDistractors > 0 {
            let shuffledOthers = otherUserIds.shuffled()
            selectedIds.append(contentsOf: shuffledOthers.prefix(neededDistractors))
        }
        return selectedIds.shuffled()
    }

    static func makeDayKey(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func getOrGenerateHints(for user: User, on db: any Database) async throws -> [Hint] {
        let userID = try user.requireID()
        let customHints = try await Hint.query(on: db)
            .filter(\.$user.$id == userID)
            .sort(\.$revealOrder, .ascending)
            .all()

        if customHints.count >= 3 {
            return customHints
        }

        var hints = customHints
        var existingOrders = Set(hints.map(\.revealOrder))

        func addFallbackHint(type: String, text: String) throws {
            var order = 1
            while existingOrders.contains(order) {
                order += 1
            }
            existingOrders.insert(order)
            let hint = try Hint(
                userID: userID,
                type: type,
                text: text,
                revealOrder: order
            )
            hints.append(hint)
        }

        if hints.count < 3, let dept = user.department, !dept.isEmpty {
            try addFallbackHint(type: "department", text: "Departmanım: \(dept)")
        }

        if hints.count < 3, let startDate = user.startDate {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: startDate)
            try addFallbackHint(type: "seniority", text: "İşe başlama yılım: \(year)")
        }

        if hints.count < 3 {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = .current
            formatter.locale = Locale(identifier: "tr_TR")
            formatter.dateFormat = "MMMM"
            let month = formatter.string(from: user.birthDate)
            try addFallbackHint(type: "habit", text: "Doğum günüm bu ayda: \(month)")
        }

        while hints.count < 3 {
            try addFallbackHint(type: "yesno", text: "Adımın baş harfi A-M aralığındadır.")
        }

        return hints.sorted(by: { $0.revealOrder < $1.revealOrder })
    }
}
