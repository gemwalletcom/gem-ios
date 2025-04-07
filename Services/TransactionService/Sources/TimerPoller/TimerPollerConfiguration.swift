// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct TimerPollerConfiguration: Sendable {
    let maxInterval: Duration
    let idleInterval: Duration
    let stepFactor: Double

    init(
        maxInterval: Duration,
        idleInterval: Duration,
        stepFactor: Double
    ) {
        self.maxInterval = maxInterval
        self.idleInterval = idleInterval
        self.stepFactor = stepFactor
    }
}

extension TimerPollerConfiguration {
    static let `default` = TimerPollerConfiguration(
        maxInterval: .seconds(10), // maximum allowed poll interval
        idleInterval: .seconds(5), // poll interval when there are no pending transactions
        stepFactor: 1.5 // factor by which to multiply the interval when stepping up,
    )
}
