// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
import WalletSessionService

public struct BalanceUpdateService: BalanceUpdater {
    private let balanceService: BalanceService
    private let walletSessionService: any WalletSessionManageable

    public init(
        balanceService: BalanceService,
        walletSessionService: any WalletSessionManageable
    ) {
        self.balanceService = balanceService
        self.walletSessionService = walletSessionService
    }

    public func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        await balanceService.updateBalance(
            for: try walletSessionService.getWallet(walletId: walletId),
            assetIds: assetIds
        )
    }

    // add asset to asset store and create balance store record
    public func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws {
        try balanceService.addAssetsBalancesIfMissing(
            assetIds: assetIds,
            wallet: walletSessionService.getWallet(walletId: walletId),
            isEnabled: isEnabled
        )
    }
}
