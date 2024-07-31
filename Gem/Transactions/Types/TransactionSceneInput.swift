// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct TransactionSceneInput {
    let transactionId: String
    let walletId: WalletId

    var transactionRequest: TransactionsRequest {
        TransactionsRequest(
            walletId: walletId.id,
            type: .transaction(id: transactionId),
            limit: 1
        )
    }
}
