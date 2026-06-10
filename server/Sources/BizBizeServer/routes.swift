import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async -> String in
        "BizBize API"
    }

    try app.register(collection: AuthController())
}
