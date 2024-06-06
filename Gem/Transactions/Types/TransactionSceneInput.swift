// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct TransactionSceneInput {
    let transactionId: String
    let wallet: Wallet
    
    var transactionRequest: TransactionsRequest {
        TransactionsRequest(
            walletId: wallet.id,
            type: .transaction(id: transactionId),
            limit: 1
        )
    }
}
