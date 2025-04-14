// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor JobRunner {
    private let config: JobRunnerConfiguration
    private var tasks: [String: Task<Void, Never>] = [:]

    public init(config: JobRunnerConfiguration) {
        self.config = config
    }

    public func addJob(job: Job) {
        print("[JobRunner] Adding job with ID: \(job.id)")

        tasks[job.id]?.cancel()

        let task = Task {
            print("[JobRunner] Starting job task for ID: \(job.id)")
            await runJob(job)
            print("[JobRunner] Finished job task for ID: \(job.id)")
            removeJob(for: job.id)
        }

        tasks[job.id] = task
    }

    public func cancelJob(id: String) {
        tasks[id]?.cancel()
        removeJob(for: id)
    }

    public func stopAll() {
        tasks.forEach { $0.value.cancel() }
        tasks.removeAll()
    }
}

// MARK: - Private

extension JobRunner {
    private func removeJob(for id: String) {
        tasks.removeValue(forKey: id)
    }

    private func runJob(_ job: Job) async {
        var currentInterval = RetryIntervalCalculator.initialInterval(for: config)
        print("[JobRunner] Job \(job.id) initial interval: \(currentInterval)")

        while !Task.isCancelled {
            print("[JobRunner] Running job \(job.id)")
            let status = await job.run()
            print("[JobRunner] Job \(job.id) returned status: \(status)")

            switch status {
            case .success, .failure: return
            case .retry(let delay):
                print("[JobRunner] Job \(job.id) wants to retry in \(delay)")
                let newInterval = RetryIntervalCalculator.nextInterval(
                    config: config,
                    currentInterval: currentInterval,
                    requestedDelay: delay
                )
                print("[JobRunner] Job \(job.id) updating interval from \(currentInterval) to \(newInterval)")
                currentInterval = newInterval
                try? await Task.sleep(for: newInterval)
            }
        }
    }
}
