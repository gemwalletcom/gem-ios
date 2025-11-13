// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ScanTransactionPayload {
    static func mock(type: TransactionType = .transfer, assetId: AssetId = AssetId(chain: .sui)) -> Self {
        .init(
            origin: .mock(assetId: assetId, address: "orig"),
            target: .mock(assetId: assetId, address: "tgt"),
            website: nil,
            type: type
        )
    }
}
