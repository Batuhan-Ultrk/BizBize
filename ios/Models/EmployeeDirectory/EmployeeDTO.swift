import Foundation

struct EmployeeDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let department: String?
    let profilePhoto: String?
    let birthDate: Date
}

extension EmployeeDTO {
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return "\(first)\(last)".uppercased()
    }

    var formattedBirthDate: String {
        birthDate.formatted(date: .abbreviated, time: .omitted)
    }
}
