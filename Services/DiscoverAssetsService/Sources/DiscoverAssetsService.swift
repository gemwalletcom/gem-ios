// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import ChainService
import BalanceService
import Preferences

public struct DiscoverAssetsService: Sendable {
    private let balanceService: BalanceService
    private let assetsService: any GemAPIAssetsListService

    public init(
        balanceService: BalanceService,
        assetsService: any GemAPIAssetsListService = GemAPIService.shared
    ) {
        self.balanceService = balanceService
        self.assetsService = assetsService
    }

    public func updateBalance(
        deviceId: String,
        wallet: Wallet,
        fromTimestamp: Int
    ) async throws -> AssetUpdate {
        if WalletPreferences(walletId: wallet.id).isEmptyWallet {
            return AssetUpdate(walletId: wallet.walletId, assetIds: [])
        }
        let assetIds = try await assetsService
            .getAssetsByDeviceId(
                deviceId: deviceId,
                walletIndex: wallet.index.asInt,
                fromTimestamp: fromTimestamp
            )

        let assets: [AssetId] = await balanceService
            .updateBalance(for: wallet, assetIds: assetIds)
            .filter { $0.type.available.or(.zero) > 1 }
            .map { $0.assetId }

        return AssetUpdate(
            walletId: wallet.walletId,
            assetIds: assets
        )
    }
}
