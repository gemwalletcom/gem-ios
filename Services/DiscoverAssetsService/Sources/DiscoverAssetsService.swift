// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import ChainService
import BalanceService

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
        let assetIds = try await assetsService
            .getAssetsByDeviceId(
                deviceId: deviceId,
                walletIndex: wallet.index.asInt,
                fromTimestamp: fromTimestamp
            )

        let assets: [AssetId] = await balanceService
            .updateBalance(for: wallet, assetIds: assetIds)
            .compactMap {
                guard $0.type.available?.isZero == false else { return nil }
                return $0.assetId
            }

        return AssetUpdate(
            walletId: wallet.walletId,
            assetIds: assets
        )
    }
}
