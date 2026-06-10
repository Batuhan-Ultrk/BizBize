import Foundation

struct HomeInfoResponseDTO: Decodable {
    let firstName: String?
    let birthdayCount: Int
    let activeSurveyCount: Int
    let announcementCount: Int
    let mysteryEmployeeTime: String?

    enum CodingKeys: String, CodingKey {
        case firstName
        case birthdayCount
        case activeSurveyCount
        case activePollCount
        case announcementCount
        case mysteryEmployeeTime
    }

    init(
        firstName: String?,
        birthdayCount: Int,
        activeSurveyCount: Int,
        announcementCount: Int,
        mysteryEmployeeTime: String?
    ) {
        self.firstName = firstName
        self.birthdayCount = birthdayCount
        self.activeSurveyCount = activeSurveyCount
        self.announcementCount = announcementCount
        self.mysteryEmployeeTime = mysteryEmployeeTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        birthdayCount = try container.decodeIfPresent(Int.self, forKey: .birthdayCount) ?? 0
        activeSurveyCount = try container.decodeIfPresent(Int.self, forKey: .activeSurveyCount)
            ?? container.decodeIfPresent(Int.self, forKey: .activePollCount)
            ?? 0
        announcementCount = try container.decodeIfPresent(Int.self, forKey: .announcementCount) ?? 0
        mysteryEmployeeTime = try container.decodeIfPresent(String.self, forKey: .mysteryEmployeeTime)
    }
}
