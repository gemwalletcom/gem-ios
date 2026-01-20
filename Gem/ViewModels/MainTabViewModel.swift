// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import GemstonePrimitives
import Preferences

struct MainTabViewModel {
    let wallet: Wallet

    var walletId: WalletId {
        wallet.walletId
    }

    var transactionsCountRequest: TransactionsCountRequest {
        TransactionsCountRequest(walletId: walletId, state: .pending)
    }
    
    var isMarketEnabled: Bool {
        false //TODO: Disabled. Preferences.standard.isDeveloperEnabled && wallet.type == .multicoin
    }
        
    var isCollectionsEnabled: Bool {
        switch wallet.type {
        case .multicoin: true
        case .single, .privateKey, .view:
            wallet.accounts.first?.chain.isNFTSupported ?? false
        }
    }
}
