import Foundation

struct UpdateUserProfileRequestDTO: Codable {
    let department: String?
    let startDate: Date?
    let profilePhoto: String?
}

struct SaveProfileHintsRequestDTO: Codable {
    let hints: [ProfileHintRequestDTO]
}

struct ProfileHintRequestDTO: Codable, Identifiable {
    var id: Int { revealOrder }

    let type: String
    let text: String
    let revealOrder: Int
}

enum ProfileHintType: String, CaseIterable, Identifiable {
    case habit
    case seniority
    case yesno
    case hobby
    case funFact

    var id: String { rawValue }

    var title: String {
        switch self {
        case .habit:
            return "Alışkanlık"
        case .seniority:
            return "Kıdem"
        case .yesno:
            return "Evet/Hayır"
        case .hobby:
            return "Hobi"
        case .funFact:
            return "Bilinmeyen"
        }
    }
}
