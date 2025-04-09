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
