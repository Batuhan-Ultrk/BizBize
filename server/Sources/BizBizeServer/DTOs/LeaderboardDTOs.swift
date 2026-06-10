import Vapor

struct LeaderboardEntryDTO: Content {
    let rank: Int
    let user: PublicUserDTO
    let weeklyPoints: Int
    let totalPoints: Int
}

struct LeaderboardResponseDTO: Content {
    let topTen: [LeaderboardEntryDTO]
    let myEntry: LeaderboardEntryDTO?
}
