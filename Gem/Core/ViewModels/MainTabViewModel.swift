// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct MainTabViewModel {
    let wallet: Wallet

    var walletId: WalletId {
        wallet.walletId
    }
}
