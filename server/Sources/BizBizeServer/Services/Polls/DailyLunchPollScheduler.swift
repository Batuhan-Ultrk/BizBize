import Fluent
import Vapor
import NIOCore

struct DailyLunchPollScheduler: LifecycleHandler {
    func didBoot(_ application: Application) throws {
        let task = application.eventLoopGroup.next().scheduleRepeatedTask(
            initialDelay: .seconds(5),
            delay: .minutes(1)
        ) { _ in
            application.eventLoopGroup.next().execute {
                Task {
                    do {
                        _ = try await DailyLunchPollService.ensureToday(on: application.db)
                    } catch {
                        application.logger.error("Daily lunch poll scheduler failed: \(String(reflecting: error))")
                    }
                }
            }
        }

        application.storage[DailyLunchPollSchedulerStorageKey.self] = task
    }

    func shutdown(_ application: Application) {
        application.storage[DailyLunchPollSchedulerStorageKey.self]?.cancel()
    }
}

private struct DailyLunchPollSchedulerStorageKey: StorageKey {
    typealias Value = RepeatedTask
}
