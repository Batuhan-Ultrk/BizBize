import Vapor

extension CreateAnnouncementRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty && .count(...140))
        validations.add("body", as: String.self, is: !.empty)
    }
}

extension RSVPAnnouncementRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {}
}
