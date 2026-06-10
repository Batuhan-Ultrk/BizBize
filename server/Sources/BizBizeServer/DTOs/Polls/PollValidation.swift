import Vapor

extension CreatePollRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("question", as: String.self, is: !.empty)
        validations.add("options", as: [String].self, is: .count(2...5))
    }
}

extension VotePollRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {}
}

extension VoteDailyLunchPollRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {}
}
