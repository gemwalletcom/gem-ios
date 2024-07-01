// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct AddNodeResult {
    let chainID: String?
    let blockNumber: String
    let latency: LatencyMeasureService.Latency
    let isInSync: Bool

    init(chainID: String?, blockNumber: String, isInSync: Bool, latency: LatencyMeasureService.Latency) {
        self.chainID = chainID
        self.blockNumber = blockNumber
        self.isInSync = isInSync
        self.latency = latency
    }
}
