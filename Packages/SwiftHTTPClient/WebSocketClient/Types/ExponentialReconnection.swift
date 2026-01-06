// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol Reconnectable: Sendable {
    func reconnectAfter(attempt: Int) -> TimeInterval
}

public struct ExponentialReconnection: Reconnectable {
    public let multiplier: Double
    public let maxDelay: TimeInterval

    public init(
        multiplier: Double = 0.3,
        maxDelay: TimeInterval = 60
    ) {
        self.multiplier = multiplier
        self.maxDelay = maxDelay
    }

    public func reconnectAfter(attempt: Int) -> TimeInterval {
        min(multiplier * exp(Double(attempt)), maxDelay)
    }
}
