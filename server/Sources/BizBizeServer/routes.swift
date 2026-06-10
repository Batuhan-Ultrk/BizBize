import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async -> String in
        "BizBize API"
    }

    try app.register(collection: AuthController())
    try app.register(collection: AnnouncementController())
    try app.register(collection: PollController())
    try app.register(collection: DailyChallengeController())
    try app.register(collection: LeaderboardController())
    try app.register(collection: UserController())
    try app.register(collection: HomeController())
    try app.register(collection: ScoreController())
}
