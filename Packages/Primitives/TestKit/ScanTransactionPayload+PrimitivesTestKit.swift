// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ScanTransactionPayload {
    static func mock(type: TransactionType = .transfer, chain: Chain = .sui) -> Self {
        .init(
            origin: .mock(chain: chain, address: "orig"),
            target: .mock(chain: chain, address: "tgt"),
            website: nil,
            type: type
        )
    }
}
