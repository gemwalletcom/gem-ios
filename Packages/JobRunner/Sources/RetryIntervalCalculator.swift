// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RetryIntervalCalculator {
    static func initialInterval(for config: JobConfiguration) -> Duration {
        switch config {
        case let .fixed(duration, _): duration
        case let .adaptive(adaptive, _): adaptive.initialInterval
        }
    }

    static func nextInterval(
        config: JobConfiguration,
        currentInterval: Duration
    ) -> Duration {
        switch config {
        case let .fixed(duration, _):
            duration
        case let .adaptive(config, _):
            max(
                config.initialInterval,
                min(currentInterval * config.stepFactor, config.maxInterval)
            )
        }
    }
}
