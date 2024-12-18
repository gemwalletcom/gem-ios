// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct MainTabViewModel {
    let wallet: Wallet

    var walletId: WalletId {
        wallet.walletId
    }

    var transactionsCountRequest: TransactionsCountRequest {
        TransactionsCountRequest(walletId: walletId.id, state: .pending)
    }
}
