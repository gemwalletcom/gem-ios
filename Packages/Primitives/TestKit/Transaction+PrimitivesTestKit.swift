// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Transaction {
    static func mock(
        type: TransactionType = .transfer,
        state: TransactionState = .confirmed,
        direction: TransactionDirection = .incoming,
        assetId: AssetId = .mock(),
        from: String = "",
        to: String = "",
        value: String = "",
        memo: String? = nil,
        metadata: AnyCodableValue? = nil
    ) -> Transaction {
        Transaction(
            id: TransactionId(chain: .ethereum, hash: "1"),
            assetId: assetId,
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
