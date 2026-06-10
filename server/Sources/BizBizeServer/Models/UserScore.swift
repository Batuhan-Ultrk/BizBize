import Fluent
import Vapor
import struct Foundation.UUID

final class UserScore: Model, Content, @unchecked Sendable {
    static let schema = "user_scores"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "weekly_points")
    var weeklyPoints: Int

    @Field(key: "total_points")
    var totalPoints: Int

    @Field(key: "monthly_engagement_score")
    var monthlyEngagementScore: Int

    init() {}

    init(
        id: UUID? = nil,
        userID: User.IDValue,
        weeklyPoints: Int,
        totalPoints: Int,
        monthlyEngagementScore: Int
    ) {
        self.id = id
        self.$user.id = userID
        self.weeklyPoints = weeklyPoints
        self.totalPoints = totalPoints
        self.monthlyEngagementScore = monthlyEngagementScore
    }
}
