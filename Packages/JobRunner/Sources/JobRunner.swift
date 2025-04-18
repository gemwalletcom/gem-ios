// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor JobRunner {
    private let config: JobRunnerConfiguration
    private var tasks: [String: Task<Void, Never>] = [:]

    public init(config: JobRunnerConfiguration) {
        self.config = config
    }

    public func addJob(job: Job) {
        tasks[job.id]?.cancel()

        let task = Task {
            await runJob(job)
            removeJob(for: job.id)
        }

        tasks[job.id] = task
    }

    public func cancelJob(id: String) {
        tasks[id]?.cancel()
        removeJob(for: id)
    }

    public func stopAll() {
        tasks.forEach { cancelJob(id: $0.key) }
    }
}

// MARK: - Private

extension JobRunner {
    private func removeJob(for id: String) {
        tasks.removeValue(forKey: id)
    }

    private func runJob(_ job: Job) async {
        var currentInterval = RetryIntervalCalculator.initialInterval(for: config)

        while !Task.isCancelled {
            let status = await job.run()
            switch status {
            case .success, .failure: return
            case .retry(let delay):
                let newInterval = RetryIntervalCalculator.nextInterval(
                    config: config,
                    currentInterval: currentInterval,
                    requestedDelay: delay
                )
                currentInterval = newInterval
                try? await Task.sleep(for: newInterval)
            }
        }
    }
}
