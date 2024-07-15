// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

enum NodeStatusInfo {
    case result(blockNumber: BigInt, latency: LatencyMeasureService.Latency)
    case error(error: Error)
}
