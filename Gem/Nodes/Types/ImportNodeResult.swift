// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct ImportNodeResult {
    let chainID: String?
    let blockNumber: String
    let isInSync: Bool

    init(chainID: String?, blockNumber: String, isInSync: Bool) {
        self.chainID = chainID
        self.blockNumber = blockNumber
        self.isInSync = isInSync
    }
}
