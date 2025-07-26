// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AdaptiveConfiguration: Sendable {
    public let initialInterval: Duration
    public let maxInterval: Duration
    public let stepFactor: Double

    public init(
        initialInterval: Duration,
        maxInterval: Duration,
        stepFactor: Double
    ) {
        self.initialInterval = min(initialInterval, maxInterval)
        self.maxInterval = maxInterval
        self.stepFactor = stepFactor
    }
}
