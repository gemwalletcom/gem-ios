// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
import Store

struct BalanceUpdateService: BalanceUpdater {
    private let balanceService: BalanceService
    private let walletStore: WalletStore

    init(
        balanceService: BalanceService,
        walletStore: WalletStore
    ) {
        self.balanceService = balanceService
        self.walletStore = walletStore
    }

    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        guard let wallet = try walletStore.getWallet(id: walletId.id) else {
            throw AnyError("Can't get a wallet, walletId: \(walletId.id)")
        }
        await balanceService.updateBalance(for: wallet, assetIds: assetIds)
    }

    // add asset to asset store and create balance store record
    func enableBalances(for walletId: WalletId, assetIds: [AssetId]) throws {
        guard let wallet = try walletStore.getWallet(id: walletId.id) else {
            throw AnyError("Can't get a wallet, walletId: \(walletId.id)")
        }
        try balanceService.addAssetsBalancesIfMissing(assetIds: assetIds, wallet: wallet)
    }
}
