// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol BalancerUpdater: Sendable {
    func updateBalance(walletId: WalletId, asset: AssetId, address: String) async throws -> [AssetBalanceChange]
    func updateBalance(for wallet: Wallet, assetIds: [AssetId]) async
}
