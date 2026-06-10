@testable import BizBizeServer
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct BizBizeServerTests {
    private func withApp(autoMigrate: Bool = false, _ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            if autoMigrate {
                try await app.autoMigrate()
            }
            try await test(app)
            if autoMigrate {
                try await app.autoRevert()
            }
        } catch {
            if autoMigrate {
                try? await app.autoRevert()
            }
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Test API Root Route")
    func apiRoot() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "BizBize API")
            })
        }
    }
}
