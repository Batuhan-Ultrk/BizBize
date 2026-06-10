import Fluent
import Vapor
import NIOCore
import Foundation

struct SchedulerService: LifecycleHandler {
    func didBoot(_ application: Application) throws {
        let task = application.eventLoopGroup.next().scheduleRepeatedTask(
            initialDelay: .seconds(5),
            delay: .minutes(1)
        ) { _ in
            application.eventLoopGroup.next().execute {
                Task {
                    do {
                        let now = Date()
                        let db = application.db

                        // 1. Daily Challenge selection
                        _ = try await DailyChallengeService.ensureToday(on: db, now: now)

                        // 2. Weekly Leaderboard reset (Mondays)
                        try await checkWeeklyReset(on: db, now: now, logger: application.logger)

                        // 3. Monthly Engagement calculation and reset (First day of month)
                        try await checkMonthlyReset(on: db, now: now, logger: application.logger)

                    } catch {
                        application.logger.error("Scheduler service tick failed: \(String(reflecting: error))")
                    }
                }
            }
        }

        application.storage[SchedulerServiceStorageKey.self] = task
    }

    func shutdown(_ application: Application) {
        application.storage[SchedulerServiceStorageKey.self]?.cancel()
    }

    private func checkWeeklyReset(on db: any Database, now: Date, logger: Logger) async throws {
        let calendar = Calendar.current
        // Weekday 2 is Monday (1 is Sunday, 2 is Monday in Gregorian calendar)
        guard calendar.component(.weekday, from: now) == 2 else {
            return
        }

        let todayKey = DailyChallengeService.makeDayKey(from: now) // yyyy-MM-dd
        let stateKey = "last_weekly_reset"

        let state = try await SystemState.find(stateKey, on: db)
        if state?.value == todayKey {
            // Already did reset today
            return
        }

        logger.info("Executing weekly leaderboard reset...")
        // Set weeklyPoints of all user_scores to 0
        try await UserScore.query(on: db)
            .set(\.$weeklyPoints, to: 0)
            .update()

        if let existing = state {
            existing.value = todayKey
            try await existing.save(on: db)
        } else {
            let newState = SystemState(key: stateKey, value: todayKey)
            try await newState.save(on: db)
        }
        logger.info("Weekly leaderboard reset completed.")
    }

    private func checkMonthlyReset(on db: any Database, now: Date, logger: Logger) async throws {
        let calendar = Calendar.current
        // Day 1 of the month
        guard calendar.component(.day, from: now) == 1 else {
            return
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM"
        let currentMonthKey = formatter.string(from: now) // yyyy-MM
        let stateKey = "last_monthly_reset"

        let state = try await SystemState.find(stateKey, on: db)
        if state?.value == currentMonthKey {
            // Already calculated for this month transition
            return
        }

        logger.info("Executing monthly engagement check and badge distribution...")
        // 1. Calculate previous month label (e.g. "Haziran 2026")
        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let trFormatter = DateFormatter()
        trFormatter.locale = Locale(identifier: "tr_TR")
        trFormatter.calendar = Calendar(identifier: .gregorian)
        trFormatter.timeZone = .current
        trFormatter.dateFormat = "MMMM yyyy"
        let periodLabel = trFormatter.string(from: lastMonthDate)

        // 2. Find all users with monthlyEngagementScore >= 30
        let highEngagementScores = try await UserScore.query(on: db)
            .filter(\.$monthlyEngagementScore >= 30)
            .all()

        for score in highEngagementScores {
            let userID = score.$user.id
            let badge = Badge(
                userID: userID,
                type: BadgeType.monthlySocial.rawValue,
                earnedAt: now,
                periodLabel: periodLabel
            )
            try await badge.save(on: db)
            logger.info("Awarded Monthly Social badge to user \(userID) for \(periodLabel)")
        }

        // 3. Reset monthlyEngagementScore of all user_scores to 0
        try await UserScore.query(on: db)
            .set(\.$monthlyEngagementScore, to: 0)
            .update()

        if let existing = state {
            existing.value = currentMonthKey
            try await existing.save(on: db)
        } else {
            let newState = SystemState(key: stateKey, value: currentMonthKey)
            try await newState.save(on: db)
        }
        logger.info("Monthly engagement reset completed.")
    }
}

private struct SchedulerServiceStorageKey: StorageKey {
    typealias Value = RepeatedTask
}
