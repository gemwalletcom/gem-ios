// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol BalanceUpdater: Sendable {
    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws
    func enableBalances(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws
}
