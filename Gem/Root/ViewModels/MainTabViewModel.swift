// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import GemstonePrimitives

struct MainTabViewModel {
    let wallet: Wallet

    var walletId: WalletId {
        wallet.walletId
    }

    var transactionsCountRequest: TransactionsCountRequest {
        TransactionsCountRequest(walletId: walletId.id, state: .pending)
    }
    
    var isCollectionsEnabled: Bool {
        switch wallet.type {
        case .multicoin: true
        case .single, .privateKey, .view:
            wallet.accounts.first?.chain.isNFTSupported ?? false
        }
    }
}
