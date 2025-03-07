// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
@preconcurrency import Keystore

struct BalanceUpdateService: BalanceUpdater {
    private let balanceService: BalanceService
    private let keystore: any Keystore

    init(
        balanceService: BalanceService,
        keystore: any Keystore
    ) {
        self.balanceService = balanceService
        self.keystore = keystore
    }

    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        let wallet = try keystore.getWallet(walletId)
        await balanceService.updateBalance(for: wallet, assetIds: assetIds)
    }

    // add asset to asset store and create balance store record
    func enableBalances(for walletId: WalletId, assetIds: [AssetId]) throws {
        let wallet = try keystore.getWallet(walletId)
        try balanceService.addAssetsBalancesIfMissing(assetIds: assetIds, wallet: wallet)
    }
}
