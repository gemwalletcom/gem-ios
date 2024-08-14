// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct Latency {
    let type: LatencyType
    let value: Double

    static func from(duration: Double) -> Latency {
        Latency(
            type: LatencyType.from(duration: duration),
            value: duration
        )
    }
}
