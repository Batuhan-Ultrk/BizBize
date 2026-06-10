import Fluent
import Vapor
import Foundation

struct DailyLunchPollService {
    static let question = "Bugün öğle yemeği?"

    static let options: [(key: DailyLunchPollOption, text: String)] = [
        (.home, "Evden getirdim"),
        (.outside, "Dışarıda yiyeceğim"),
        (.order, "Ofise yemek isteyelim")
    ]

    static func ensureToday(on database: any Database, now: Date = Date()) async throws -> Poll? {
        guard shouldExistToday(now: now) else {
            return nil
        }

        let dayKey = makeDayKey(from: now)
        if let existing = try await Poll.query(on: database)
            .filter(\.$type == .dailyLunch)
            .filter(\.$dayKey == dayKey)
            .first()
        {
            return existing
        }

        let poll = Poll(
            createdByUserID: nil,
            type: .dailyLunch,
            question: question,
            expiresAt: makeClosingDate(from: now),
            targetUserIds: [],
            dayKey: dayKey
        )
        try await poll.save(on: database)

        for (index, option) in options.enumerated() {
            let pollOption = try PollOption(
                pollID: poll.requireID(),
                text: option.text,
                key: option.key.rawValue,
                displayOrder: index
            )
            try await pollOption.save(on: database)
        }

        return poll
    }

    static func makeDayKey(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func shouldExistToday(now: Date) -> Bool {
        Calendar.current.component(.hour, from: now) >= 9
    }

    private static func makeClosingDate(from date: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? date
    }
}
