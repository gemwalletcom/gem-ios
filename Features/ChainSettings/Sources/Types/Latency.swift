// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct Latency: Sendable {
    public let type: LatencyType
    public let value: Double

    public init(type: LatencyType, value: Double) {
        self.type = type
        self.value = value
    }
    
    public static func from(duration: Double) -> Latency {
        Latency(
            type: LatencyType.from(duration: duration),
            value: duration
        )
    }
}
