import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct HomeDashboardResponseDTO: Content {
    let birthdayCount: Int
    let activePollCount: Int
    let announcementCount: Int
    let upcomingBirthdays: [BirthdayUserDTO]
}

struct BirthdayUserDTO: Content {
    let id: UUID
    let firstName: String
    let lastName: String
    let birthDate: Date
    let profilePhoto: String?
}

struct EmployeeDirectoryResponseDTO: Content {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let department: String?
    let profilePhoto: String?
    let birthDate: Date
}
