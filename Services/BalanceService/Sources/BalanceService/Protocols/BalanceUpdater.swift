// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol BalancerUpdater {
    func updateBalance(walletId: String, asset: AssetId, address: String) async
}
