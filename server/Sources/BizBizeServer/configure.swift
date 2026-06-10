import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    configureServer(app)

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
//    app.migrations.add(MakeUserTokenUserIDUnique())
    app.migrations.add(CreatePasswordResetToken())
    app.migrations.add(CreateAnnouncement())
    app.migrations.add(CreateAnnouncementRSVP())
    app.migrations.add(CreatePoll())
    app.migrations.add(CreatePollOption())
    app.migrations.add(CreatePollVote())
    app.migrations.add(CreateHint())
    app.migrations.add(CreateDailyChallenge())
    app.migrations.add(CreateDailyChallengeCandidate())
    app.migrations.add(CreateGuess())
    app.migrations.add(CreateUserScore())
    app.migrations.add(CreateBadge())
    app.migrations.add(CreateScoreEvent())
    app.migrations.add(CreateSystemState())

    app.lifecycle.use(DailyLunchPollScheduler())
    app.lifecycle.use(SchedulerService())

    // register routes
    try routes(app)
}

private func configureServer(_ app: Application) {
    app.http.server.configuration.hostname = Environment.get("SERVER_HOSTNAME") ?? "0.0.0.0"

    if let port = Environment.get("SERVER_PORT").flatMap(Int.init) {
        app.http.server.configuration.port = port
    }
}
