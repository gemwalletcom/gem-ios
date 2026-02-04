// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
import EarnService
import WalletSessionService

struct BalanceUpdateService: BalanceUpdater {
    private let balanceService: BalanceService
    private let earnBalanceService: any EarnBalanceServiceable
    private let walletSessionService: any WalletSessionManageable

    init(
        balanceService: BalanceService,
        earnBalanceService: any EarnBalanceServiceable,
        walletSessionService: any WalletSessionManageable
    ) {
        self.balanceService = balanceService
        self.earnBalanceService = earnBalanceService
        self.walletSessionService = walletSessionService
    }

    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        let wallet = try walletSessionService.getWallet(walletId: walletId)
        async let updateBalance: Void = balanceService.updateBalance(for: wallet, assetIds: assetIds)
        async let updateEarn: Void = updateEarnPositions(wallet: wallet, assetIds: assetIds)
        let _ = await (updateBalance, updateEarn)
    }

    // add asset to asset store and create balance store record
    func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws {
        try balanceService.addAssetsBalancesIfMissing(
            assetIds: assetIds,
            wallet: walletSessionService.getWallet(walletId: walletId),
            isEnabled: isEnabled
        )
    }

    private func updateEarnPositions(wallet: Wallet, assetIds: [AssetId]) async {
        await withTaskGroup(of: Void.self) { group in
            for assetId in assetIds {
                group.addTask {
                    guard let account = try? wallet.account(for: assetId.chain) else {
                        return
                    }
                    await earnBalanceService.updatePositions(
                        walletId: wallet.walletId,
                        assetId: assetId,
                        address: account.address
                    )
                }
            }

            for await _ in group { }
        }
    }
}
