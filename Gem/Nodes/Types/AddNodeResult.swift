// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

struct AddNodeResult {
    let chainID: String?
    let blockNumber: BigInt
    let latency: LatencyMeasureService.Latency
    let isInSync: Bool

    init(chainID: String?, blockNumber: BigInt, isInSync: Bool, latency: LatencyMeasureService.Latency) {
        self.chainID = chainID
        self.blockNumber = blockNumber
        self.isInSync = isInSync
        self.latency = latency
    }
}
