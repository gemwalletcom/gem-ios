// Copyright (c). Gem Wallet. All rights reserved.

import BigInt

public struct NodeStatus: Sendable {
    public let chainId: String
    public let latestBlockNumber: BigInt
    public let latency: Latency

    public init(chainId: String, latestBlockNumber: BigInt, latency: Latency) {
        self.chainId = chainId
        self.latestBlockNumber = latestBlockNumber
        self.latency = latency
    }

}
