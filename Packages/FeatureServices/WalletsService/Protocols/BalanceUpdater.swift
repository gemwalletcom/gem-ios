// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol BalanceUpdater: Sendable {
    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws
    func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws
}
