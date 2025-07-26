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
        let startTime = clock.now

        while !Task.isCancelled {
            if let limit = job.configuration.timeLimit,
               startTime.duration(to: clock.now) >= limit {
                NSLog("job \(job.id) completed by time limit")
                return
            }

            switch await job.run() {
            case .complete:
                do {
                    try await job.onComplete()
                }
                catch {
                    NSLog("job \(job.id) completed with error: \(error)")
                }
                return

            case .retry:
                interval = RetryIntervalCalculator.nextInterval(
                    config: job.configuration,
                    currentInterval: interval
                )
                try? await clock.sleep(
                    until: clock.now.advanced(by: interval)
                )
            }
        }
    }
}
