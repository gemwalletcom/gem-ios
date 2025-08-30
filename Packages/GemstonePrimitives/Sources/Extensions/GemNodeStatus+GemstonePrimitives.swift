// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives
import BigInt

public extension Gemstone.GemNodeStatus {
    func map() throws -> NodeStatus {
        .result(
            blockNumber: latestBlockNumber.asBigInt,
            latency: Latency.from(duration: Double(latencyMs) / 1000.0)
        )
    }
}