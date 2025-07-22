// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Transaction {
    static func mock(
        type: TransactionType = .transfer,
        state: TransactionState = .confirmed,
        direction: TransactionDirection = .incoming,
        from: String = "",
        to: String = "",
        value: String = "",
        memo: String? = nil,
        metadata: TransactionMetadata? = nil
    ) -> Transaction {
        Transaction(
            id: "1",
            hash: "2",
            assetId: .mock(),
            from: from,
            to: to,
            contract: .none,
            type: type,
            state: state,
            blockNumber: "",
            sequence: "",
            fee: "",
            feeAssetId: .mock(),
            value: value,
            memo: memo,
            direction: direction,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: metadata,
            createdAt: .now
        )
    }
}
