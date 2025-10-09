// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives
import BigInt

extension Gemstone.NodeStatus {
    public func map() -> Primitives.NodeStatus {
        Primitives.NodeStatus(
            chainId: chainId,
            latestBlockNumber: BigInt(latestBlockNumber),
            latency: Latency.from(milliseconds: Double(latencyMs))
        )
    }
}
