// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct BalanceUpdate {
    let walletId: WalletId
    let balances: [AssetBalanceChange]
}
