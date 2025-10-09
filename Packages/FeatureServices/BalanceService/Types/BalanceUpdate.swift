// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct BalanceUpdate {
    public let walletId: String
    public let balances: [AssetBalanceChange]
}
