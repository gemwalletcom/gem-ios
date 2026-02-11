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
        let wallet = try walletSessionService.getWallet(walletId: walletId)
        await balanceService.updateBalance(for: wallet, assetIds: assetIds)
    }

    func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws {
        try balanceService.addAssetsBalancesIfMissing(
            assetIds: assetIds,
            wallet: walletSessionService.getWallet(walletId: walletId),
            isEnabled: isEnabled
        )
    }
}
