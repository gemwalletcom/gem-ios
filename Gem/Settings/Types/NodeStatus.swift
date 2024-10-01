// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

enum NodeStatus {
    case result(blockNumber: BigInt, latency: Latency)
    case error(error: any Error)
    case none
}
