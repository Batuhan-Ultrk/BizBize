import Fluent
import Vapor
import struct Foundation.Date
import struct Foundation.UUID

final class Guess: Model, Content, @unchecked Sendable {
    static let schema = "guesses"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "challenge_id")
    var challenge: DailyChallenge

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "guessed_user_id")
    var guessedUser: User

    @Field(key: "is_correct")
    var isCorrect: Bool

    @Field(key: "is_first_correct")
    var isFirstCorrect: Bool

    @Field(key: "timestamp")
    var timestamp: Date

    init() {}

    init(
        id: UUID? = nil,
        challengeID: DailyChallenge.IDValue,
        userID: User.IDValue,
        guessedUserID: User.IDValue,
        isCorrect: Bool,
        isFirstCorrect: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.$challenge.id = challengeID
        self.$user.id = userID
        self.$guessedUser.id = guessedUserID
        self.isCorrect = isCorrect
        self.isFirstCorrect = isFirstCorrect
        self.timestamp = timestamp
    }
}
