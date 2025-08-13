// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit

public extension Transaction {
    static func mock(
        id: String = "1",
        type: TransactionType = .transfer,
        assetId: AssetId = .mock(),
        metadata: TransactionMetadata? = nil
    ) -> Transaction {
        Transaction(
            id: id,
            hash: id,
            assetId: assetId,
            from: "from",
            to: "to",
            contract: nil,
            type: type,
            state: .confirmed,
            blockNumber: "1",
            sequence: "1",
            fee: "1",
            feeAssetId: assetId,
            value: "100",
            memo: nil,
            direction: .outgoing,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: metadata,
            createdAt: .now
        )
    }
}
