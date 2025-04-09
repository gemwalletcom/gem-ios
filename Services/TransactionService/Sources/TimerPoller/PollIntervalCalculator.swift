// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct PollIntervalCalculator {
    static func nextInterval(
        configuration: TimerPollerConfiguration,
        currentInterval: Duration,
        recommendedInterval: Duration
    ) -> Duration {
        let stepFactor = configuration.stepFactor
        let maxInterval = configuration.maxInterval
        let idle = configuration.idleInterval
        
        if recommendedInterval < idle {
            return recommendedInterval
        } else if recommendedInterval >= maxInterval {
            return maxInterval
        }
        
        return .min(currentInterval * stepFactor, maxInterval)
    }
}
