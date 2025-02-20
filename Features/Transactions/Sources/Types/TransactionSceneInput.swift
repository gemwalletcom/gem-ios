// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct TransactionSceneInput {
    let transactionId: String
    let walletId: WalletId

    public init(transactionId: String, walletId: WalletId) {
        self.transactionId = transactionId
        self.walletId = walletId
    }

    var transactionRequest: TransactionsRequest {
        TransactionsRequest(
            walletId: walletId.id,
            type: .transaction(id: transactionId),
            limit: 1
        )
    }
}
