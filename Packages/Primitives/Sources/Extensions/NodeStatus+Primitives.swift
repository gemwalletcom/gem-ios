// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum NodeStatus: Sendable {
    case result(blockNumber: BigInt, latency: Latency)
    case error(error: any Error)
    case none
}