// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

actor TimerPoller {
    let configuration: TimerPollerConfiguration
    private var task: Task<Void, Never>?

    init(configuration: TimerPollerConfiguration = .default) {
        self.configuration = configuration
    }

    func start(pollAction: @Sendable @escaping () async throws -> PollResult) {
        stop()
        task = Task {
            var currentInterval = configuration.idleInterval

            while !Task.isCancelled {
                do {
                    let pollResult = try await pollAction()
                    if pollResult.isActive {
                        currentInterval = PollIntervalCalculator.nextInterval(
                            configuration: configuration,
                            currentInterval: currentInterval,
                            recommendedInterval: pollResult.recommendedInterval
                        )
                    } else {
                        currentInterval = configuration.idleInterval
                    }
                } catch {
                    currentInterval = configuration.idleInterval
                }
                try? await Task.sleep(for: currentInterval)
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
    }
}

extension Duration {
    static func min(_ lhs: Duration, _ rhs: Duration) -> Duration {
        lhs < rhs ? lhs : rhs
    }

    static func max(_ lhs: Duration, _ rhs: Duration) -> Duration {
        lhs < rhs ? rhs : lhs
    }
}
