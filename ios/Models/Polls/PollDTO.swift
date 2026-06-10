import Foundation

struct PollDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let createdByUserId: UUID?
    let type: String
    let question: String
    let options: [PollOptionDTO]
    let expiresAt: Date
    let targetUserIds: [UUID]?
    let dayKey: String?
    let isClosed: Bool
    let myVoteOptionId: UUID?
    let createdAt: Date
}

struct PollOptionDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let key: String?
    let displayOrder: Int
    let voteCount: Int
}

extension PollDTO {
    var typeTitle: String {
        PollType.displayName(for: type)
    }

    var formattedCreatedAt: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    var formattedExpiresAt: String {
        expiresAt.formatted(date: .abbreviated, time: .shortened)
    }

    var totalVoteCount: Int {
        options.reduce(0) { $0 + $1.voteCount }
    }
}

enum PollType: String, CaseIterable, Identifiable {
    case manual
    case dailyLunch

    var id: String { rawValue }

    var title: String {
        Self.displayName(for: rawValue)
    }

    static func displayName(for type: String) -> String {
        switch type {
        case "manual":
            return "Manuel"
        case "dailyLunch":
            return "Yemek"
        default:
            return type
        }
    }
}

enum DailyLunchOption: String, CaseIterable, Identifiable {
    case home
    case outside
    case order

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            return "Evden getirdim"
        case .outside:
            return "Dışarıda yiyeceğim"
        case .order:
            return "Ofise yemek isteyelim"
        }
    }

    var icon: HomeIconKind {
        switch self {
        case .home:
            return .salad
        case .outside:
            return .burger
        case .order:
            return .soup
        }
    }
}
