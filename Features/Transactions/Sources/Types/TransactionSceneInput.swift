// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct TransactionSceneInput {
    let transactionId: String
    let walletId: WalletId
    let priceStore: PriceStore

    public init(transactionId: String, walletId: WalletId, priceStore: PriceStore) {
        self.transactionId = transactionId
        self.walletId = walletId
        self.priceStore = priceStore
    }

    var transactionRequest: TransactionsRequest {
        TransactionsRequest(
            walletId: walletId.id,
            type: .transaction(id: transactionId),
            limit: 1
        )
    }
}
