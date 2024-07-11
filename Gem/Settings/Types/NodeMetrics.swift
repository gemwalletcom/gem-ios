// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

struct NodeMetrics {
    let latency: LatencyMeasureService.Latency?
    let blockNumber: BigInt?
    let error: Error?
}
