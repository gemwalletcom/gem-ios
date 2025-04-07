// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum PollingDecision {
    case sleepAndIdle(Duration)
    case sleep(Duration)
}

struct PollingDecisionMaker {
    static func decide(
        configuration: TransactionPollerConfiguration,
        currentInterval: Duration,
        hasPendingTransactions: Bool,
        minBlockTime: Duration
    ) -> PollingDecision {
        if !hasPendingTransactions {
            return .sleepAndIdle(configuration.idleInterval)
        } else {
            let newInterval = PollIntervalCalculator.nextInterval(
                configuration: configuration,
                interval: currentInterval,
                blockTime: minBlockTime
            )
            return .sleep(newInterval)
        }
    }
}
