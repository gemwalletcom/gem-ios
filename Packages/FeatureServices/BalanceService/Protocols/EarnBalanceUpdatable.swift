// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol EarnBalanceUpdatable: Sendable {
    @discardableResult
    func updateEarnBalance(walletId: WalletId, chain: Chain, address: String) async -> [AssetBalanceChange]
}
