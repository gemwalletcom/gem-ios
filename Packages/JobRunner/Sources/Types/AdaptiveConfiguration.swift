// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AdaptiveConfiguration: Sendable {
    public let idleInterval: Duration
    public let maxInterval: Duration
    public let stepFactor: Double

    public init(
        idleInterval: Duration,
        maxInterval: Duration,
        stepFactor: Double
    ) {
        self.idleInterval = idleInterval
        self.maxInterval = maxInterval
        self.stepFactor = stepFactor
    }
}
