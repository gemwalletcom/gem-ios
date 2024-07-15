// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

enum NodeStatus {
    case result(blockNumber: BigInt, latency: LatencyMeasureService.Latency)
    case error(error: Error)
}
