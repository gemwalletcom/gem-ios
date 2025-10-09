// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct AddNodeResult: Sendable {
    let url: URL
    let chainID: String
    let blockNumber: BigInt
    let latency: Latency
    let isInSync: Bool

    public init(
        url: URL,
        chainID: String,
        blockNumber: BigInt,
        isInSync: Bool,
        latency: Latency
    ) {
        self.url = url
        self.chainID = chainID
        self.blockNumber = blockNumber
        self.isInSync = isInSync
        self.latency = latency
    }
}
