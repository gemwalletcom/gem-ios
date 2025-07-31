// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
import WalletSessionService

struct BalanceUpdateService: BalanceUpdater {
    private let balanceService: BalanceService
    private let walletSessionService: any WalletSessionManageable

    init(
        balanceService: BalanceService,
        walletSessionService: any WalletSessionManageable
    ) {
        self.balanceService = balanceService
        self.walletSessionService = walletSessionService
    }

    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        await balanceService.updateBalance(
            for: try walletSessionService.getWallet(walletId: walletId),
            assetIds: assetIds
        )
    }

    // add asset to asset store and create balance store record
    func enableBalances(for walletId: WalletId, assetIds: [AssetId]) throws {
        try balanceService.addAssetsBalancesIfMissing(
            assetIds: assetIds,
            wallet: walletSessionService.getWallet(walletId: walletId)
        )
    }
}
