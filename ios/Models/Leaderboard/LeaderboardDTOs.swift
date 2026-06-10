import Foundation

struct LeaderboardEntryDTO: Decodable, Identifiable, Hashable {
    let rank: Int
    let userId: UUID?
    let userIdRaw: String
    let score: Int
    let badges: [String]
    let firstName: String?
    let lastName: String?
    let displayName: String?

    var id: String {
        userIdRaw.isEmpty ? "\(rank)-\(score)" : userIdRaw
    }

    enum CodingKeys: String, CodingKey {
        case rank
        case userId
        case score
        case totalScore
        case points
        case badges
        case firstName
        case lastName
        case displayName
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        rank = try container.decodeFlexibleInt(forKey: .rank) ?? 0
        score = try container.decodeFlexibleInt(forKey: .score)
            ?? container.decodeFlexibleInt(forKey: .totalScore)
            ?? container.decodeFlexibleInt(forKey: .points)
            ?? 0

        userIdRaw = try container.decodeFlexibleString(forKey: .userId) ?? ""
        userId = UUID(uuidString: userIdRaw)
        badges = (try? container.decode([String].self, forKey: .badges)) ?? []
        firstName = try container.decodeFlexibleString(forKey: .firstName)
        lastName = try container.decodeFlexibleString(forKey: .lastName)
        displayName = try container.decodeFlexibleString(forKey: .displayName)
            ?? container.decodeFlexibleString(forKey: .name)
    }
}

struct UserScoreDTO: Decodable {
    let totalScore: Int
    let events: [ScoreEventDTO]

    enum CodingKeys: String, CodingKey {
        case totalScore
        case score
        case events
        case scoreHistory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        totalScore = try container.decodeFlexibleInt(forKey: .totalScore)
            ?? container.decodeFlexibleInt(forKey: .score)
            ?? 0
        events = (try? container.decode([ScoreEventDTO].self, forKey: .events))
            ?? (try? container.decode([ScoreEventDTO].self, forKey: .scoreHistory))
            ?? []
    }
}

struct ScoreEventDTO: Decodable, Identifiable {
    let source: String
    let points: Int
    let date: Date

    var id: String {
        "\(source)-\(points)-\(date.timeIntervalSince1970)"
    }

    enum CodingKeys: String, CodingKey {
        case source
        case points
        case date
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        source = try container.decodeFlexibleString(forKey: .source) ?? ""
        points = try container.decodeFlexibleInt(forKey: .points) ?? 0
        date = (try? container.decode(Date.self, forKey: .date))
            ?? (try? container.decode(Date.self, forKey: .createdAt))
            ?? Date(timeIntervalSince1970: 0)
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) throws -> String? {
        if let value = try decodeIfPresent(String.self, forKey: key) {
            return value
        }

        if let value = try decodeIfPresent(Int.self, forKey: key) {
            return String(value)
        }

        return nil
    }

    func decodeFlexibleInt(forKey key: Key) throws -> Int? {
        if let value = try decodeIfPresent(Int.self, forKey: key) {
            return value
        }

        if let value = try decodeIfPresent(Double.self, forKey: key) {
            return Int(value)
        }

        if let value = try decodeIfPresent(String.self, forKey: key) {
            return Int(value)
        }

        return nil
    }
}
