// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol BalanceUpdater: Sendable {
    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws
    func enableBalances(for walletId: WalletId, chains: [Chain]) throws
    func enableBalances(for walletId: WalletId, assetIds: [AssetId]) throws
}

extension BalanceUpdater {
    func enableBalances(for walletId: WalletId, chains: [Chain]) throws {
        try enableBalances(for: walletId, assetIds: chains.ids)
    }
}
