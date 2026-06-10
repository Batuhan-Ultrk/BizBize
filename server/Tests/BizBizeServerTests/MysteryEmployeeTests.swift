@testable import BizBizeServer
import VaporTesting
import Testing
import Fluent
import Foundation

@Suite("Mystery Employee & Score Tests", .serialized)
struct MysteryEmployeeTests {
    private func withApp(autoMigrate: Bool = true, _ test: (Application) async throws -> ()) async throws {
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

    private func registerUser(app: Application, email: String, name: String) async throws -> (token: String, userId: UUID) {
        var token: String = ""
        var userId: UUID = UUID()

        let registerDTO = RegisterRequestDTO(
            firstName: name,
            lastName: "Tester",
            birthDate: Date(),
            phoneNumber: "5551112233",
            email: email,
            password: "password123"
        )

        try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
            try req.content.encode(registerDTO)
        }, afterResponse: { res in
            #expect(res.status == .ok)
            let response = try res.content.decode(AuthResponseDTO.self)
            token = response.token
            userId = response.user.id
        })

        return (token, userId)
    }

    @Test("Test user profile edit and custom hints saving")
    func profileAndHints() async throws {
        try await withApp { app in
            let user = try await registerUser(app: app, email: "user1@example.com", name: "User One")
            
            // Edit profile
            let updateDTO = UpdateProfileRequestDTO(
                department: "iOS Team",
                startDate: Date(),
                profilePhoto: "http://photo.com/1.png"
            )
            try await app.testing().test(.PATCH, "auth/me", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user.token)
                try req.content.encode(updateDTO)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(PublicUserDTO.self)
                #expect(response.department == "iOS Team")
                #expect(response.profilePhoto == "http://photo.com/1.png")
            })

            // Save custom hints
            let hintsDTO = SaveHintsRequestDTO(hints: [
                SaveHintItemDTO(type: "seniority", text: "Seniority hint", revealOrder: 1),
                SaveHintItemDTO(type: "habit", text: "Habit hint", revealOrder: 2),
                SaveHintItemDTO(type: "department", text: "Department hint", revealOrder: 3)
            ])
            try await app.testing().test(.POST, "auth/me/hints", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user.token)
                try req.content.encode(hintsDTO)
            }, afterResponse: { res in
                #expect(res.status == .noContent)
            })

            // Verify hints are saved and retrieved in show detail
            try await app.testing().test(.GET, "users/\(user.userId)", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user.token)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(UserDetailResponseDTO.self)
                #expect(response.hints?.count == 3)
                #expect(response.hints?[0].text == "Seniority hint")
            })
        }
    }

    @Test("Test Daily Challenge selection and guess logic")
    func dailyChallengeAndGuessing() async throws {
        try await withApp { app in
            let user1 = try await registerUser(app: app, email: "user1@example.com", name: "User One")
            let user2 = try await registerUser(app: app, email: "user2@example.com", name: "User Two")

            // Ensure today's challenge is created
            let challenge = try await DailyChallengeService.ensureToday(on: app.db)
            #expect(challenge != nil)
            
            // Get today's challenge via API
            try await app.testing().test(.GET, "challenges/today", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user1.token)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(ChallengeResponseDTO.self)
                #expect(response.candidates.count > 0)
                #expect(response.isGuessed == false)
                #expect(response.revealedUser == nil) // Hidden during day if not guessed correctly
            })

            // Determine who is selected and make a guess
            let selectedUserId = challenge!.selectedUser.id!
            let incorrectUserId = selectedUserId == user1.userId ? user2.userId : user1.userId

            // Submit incorrect guess
            let incorrectGuessDTO = SubmitGuessRequestDTO(guessedUserId: incorrectUserId)
            try await app.testing().test(.POST, "challenges/today/guess", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user1.token)
                try req.content.encode(incorrectGuessDTO)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(ChallengeResponseDTO.self)
                #expect(response.isGuessed == true)
                #expect(response.myGuess?.isCorrect == false)
                #expect(response.revealedUser == nil) // Still hidden because they guessed wrong
            })

            // Submit correct guess from user2
            let correctGuessDTO = SubmitGuessRequestDTO(guessedUserId: selectedUserId)
            try await app.testing().test(.POST, "challenges/today/guess", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user2.token)
                try req.content.encode(correctGuessDTO)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(ChallengeResponseDTO.self)
                #expect(response.isGuessed == true)
                #expect(response.myGuess?.isCorrect == true)
                #expect(response.myGuess?.isFirstCorrect == true) // First correct guess!
                #expect(response.revealedUser != nil) // Revealed because they guessed correct
                #expect(response.revealedUser?.id == selectedUserId)
            })

            // Verify points were awarded: user2 gets +150, user1 gets 0 (guess was wrong)
            try await app.testing().test(.GET, "leaderboard", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: user2.token)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let response = try res.content.decode(LeaderboardResponseDTO.self)
                let entry2 = response.topTen.first(where: { $0.user.id == user2.userId })
                #expect(entry2?.weeklyPoints == 150)
                
                let entry1 = response.topTen.first(where: { $0.user.id == user1.userId })
                #expect(entry1?.weeklyPoints == 0)
            })
        }
    }
}
