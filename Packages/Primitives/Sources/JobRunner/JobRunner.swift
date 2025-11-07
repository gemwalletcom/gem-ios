// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor JobRunner {
    private var tasks: [String: Task<Void, Never>] = [:]
    private let clock: ContinuousClock

    public init(clock: ContinuousClock = ContinuousClock()) {
        self.clock = clock
    }

    public func addJob(job: Job) {
        tasks[job.id]?.cancel()
        tasks[job.id] = Task { [weak self] in
            await self?.runJob(job)
            await self?.removeJob(for: job.id)
        }
    }

    public func cancelJob(id: String) {
        tasks[id]?.cancel()
        removeJob(for: id)
    }

    public func stopAll() {
        tasks.keys.forEach(cancelJob)
    }
}

// MARK: - Private

extension JobRunner {
    private func removeJob(for id: String) {
        tasks.removeValue(forKey: id)
    }

    private func runJob(_ job: Job) async {
        var interval = RetryIntervalCalculator.initialInterval(for: job.configuration)
        let jobStart = clock.now
        let deadline = job.configuration.timeLimit.map { jobStart.advanced(by: $0) }

        while !Task.isCancelled {
            if let limit = job.configuration.timeLimit,
               jobStart.duration(to: clock.now) >= limit {
                #debugLog("job \(job.id) completed by time limit")
                return
            }

            let attemptStart = clock.now

            switch await job.run() {
            case .complete:
                do {
                    try await job.onComplete()
                }
                catch {
                    #debugLog("job \(job.id) completed with error: \(error)")
                }
                return
            case .retry:
                let nextAttempt = attemptStart.advanced(by: interval)
                let sleepUntil = deadline.map { min(nextAttempt, $0) } ?? nextAttempt

                if clock.now < sleepUntil {
                    try? await clock.sleep(until: sleepUntil)
                }

                interval = RetryIntervalCalculator.nextInterval(
                    config: job.configuration,
                    currentInterval: interval
                )
            }
        }
    }
}
