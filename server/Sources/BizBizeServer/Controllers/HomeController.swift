import Fluent
import Vapor
import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.UUID

struct HomeController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let protectedHome = routes
            .grouped(UserToken.authenticator())
            .grouped("home")

        protectedHome.get("dashboard", use: dashboard)
        protectedHome.get("employees", use: employees)
    }

    // MARK: - GET /home/dashboard  (anasayfaBilgiGetir)

    @Sendable
    func dashboard(req: Request) async throws -> HomeDashboardResponseDTO {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()

        // ── 1. Bugün doğum günü olan kullanıcılar ──
        let now = Date()
        let calendar = Calendar.current
        let todayMonth = calendar.component(.month, from: now)
        let todayDay   = calendar.component(.day, from: now)

        let allUsers = try await User.query(on: req.db).all()

        let birthdayUsers = allUsers.filter { u in
            let m = calendar.component(.month, from: u.birthDate)
            let d = calendar.component(.day, from: u.birthDate)
            return m == todayMonth && d == todayDay
        }

        let birthdayDTOs = try birthdayUsers.map { u in
            try BirthdayUserDTO(
                id: u.requireID(),
                firstName: u.firstName,
                lastName: u.lastName,
                birthDate: u.birthDate,
                profilePhoto: u.profilePhoto
            )
        }

        // ── 2. Aktif anket sayısı (süresi dolmamış, kullanıcının görebildiği) ──
        let allPolls = try await Poll.query(on: req.db).all()
        let activePolls = allPolls.filter { poll in
            // Süresi dolmamış
            let notExpired: Bool
            if let expiresAt = poll.expiresAt {
                notExpired = expiresAt > now
            } else {
                notExpired = true
            }
            // Kullanıcının görebildiği
            let visible: Bool
            if poll.targetUserIds.isEmpty {
                visible = true
            } else {
                visible = poll.targetUserIds.contains(userID) || poll.$createdByUser.id == userID
            }
            return notExpired && visible
        }

        // ── 3. Duyuru sayısı (kullanıcının görebildiği) ──
        let allAnnouncements = try await Announcement.query(on: req.db).all()
        let visibleAnnouncements = allAnnouncements.filter { a in
            if a.targetUserIds.isEmpty {
                return true
            }
            return a.targetUserIds.contains(userID) || a.$createdByUser.id == userID
        }

        return HomeDashboardResponseDTO(
            birthdayCount: birthdayUsers.count,
            activePollCount: activePolls.count,
            announcementCount: visibleAnnouncements.count,
            upcomingBirthdays: birthdayDTOs
        )
    }

    // MARK: - GET /home/employees  (çalışan rehberi)

    @Sendable
    func employees(req: Request) async throws -> [EmployeeDirectoryResponseDTO] {
        let _ = try req.auth.require(User.self)

        struct EmployeeListQuery: Codable {
            let search: String?
            let department: String?
        }

        let query = try req.query.decode(EmployeeListQuery.self)
        var builder = User.query(on: req.db)

        if let search = query.search, !search.trimmingCharacters(in: .whitespaces).isEmpty {
            let term = search.trimmingCharacters(in: .whitespaces)
            builder = builder.group(.or) { group in
                group.filter(\.$firstName, .custom("ilike"), "%\(term)%")
                     .filter(\.$lastName, .custom("ilike"), "%\(term)%")
                     .filter(\.$email, .custom("ilike"), "%\(term)%")
            }
        }

        if let dept = query.department, !dept.trimmingCharacters(in: .whitespaces).isEmpty {
            builder = builder.filter(\.$department == dept.trimmingCharacters(in: .whitespaces))
        }

        let users = try await builder
            .sort(\.$firstName, .ascending)
            .sort(\.$lastName, .ascending)
            .all()

        return try users.map { u in
            try EmployeeDirectoryResponseDTO(
                id: u.requireID(),
                firstName: u.firstName,
                lastName: u.lastName,
                email: u.email,
                department: u.department,
                profilePhoto: u.profilePhoto,
                birthDate: u.birthDate
            )
        }
    }
}
