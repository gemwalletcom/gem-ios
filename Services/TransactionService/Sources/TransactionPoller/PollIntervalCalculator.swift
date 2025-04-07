// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct PollIntervalCalculator {
    static func nextInterval(
        configuration: TransactionPollerConfiguration,
        interval: Duration,
        blockTime: Duration
    ) -> Duration {
        let stepFactor = configuration.stepFactor
        let maxInterval = configuration.maxInterval
        let idle = configuration.idleInterval

        if blockTime < idle {
            return blockTime
        } else if blockTime >= maxInterval {
            return maxInterval
        } else {
            return Duration.min(interval * stepFactor, maxInterval)
        }
    }
}
