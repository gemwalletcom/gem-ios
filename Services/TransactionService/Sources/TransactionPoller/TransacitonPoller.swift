// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

typealias TransactionPollAction = @Sendable () async throws -> (hasPendingTransactions: Bool, minBlockTime: Duration)

actor TransactionPoller {
    let configuration: TransactionPollerConfiguration
    private var task: Task<Void, Never>?

    init(configuration: TransactionPollerConfiguration = .default) {
        self.configuration = configuration
    }

    func start(pollAction: @escaping TransactionPollAction) {
        stop()
        task = Task {
            var currentInterval = configuration.idleInterval

            while !Task.isCancelled {
                do {
                    let (hasPendingTransactions, minBlockTime) = try await pollAction()

                    let decision = PollingDecisionMaker.decide(
                        configuration: configuration,
                        currentInterval: currentInterval,
                        hasPendingTransactions: hasPendingTransactions,
                        minBlockTime: minBlockTime
                    )

                    NSLog("[TransactionPoller] decision: \(decision)")
                    currentInterval = switch decision {
                    case let .sleepAndIdle(interval): interval
                    case let .sleep(interval): interval
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
