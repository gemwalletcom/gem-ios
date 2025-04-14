// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct RetryIntervalCalculator {
    static func initialInterval(for config: JobRunnerConfiguration) -> Duration {
        switch config {
        case let .fixed(duration): duration
        case let .adaptive(adaptive): adaptive.idleInterval
        }
    }

    static func nextInterval(
        config: JobRunnerConfiguration,
        currentInterval: Duration,
        requestedDelay: Duration
    ) -> Duration {
        switch config {
        case .fixed(let duration):
            return duration
        case .adaptive(let config):
            if requestedDelay < config.idleInterval {
                return requestedDelay
            } else if requestedDelay > config.maxInterval {
                return config.maxInterval
            }

            return .min(currentInterval * config.stepFactor, config.maxInterval)
        }
    }
}
