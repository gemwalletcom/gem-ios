// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import AssetsService
import PriceService

public struct AssetsEnablerService: AssetsEnabler {
    private let assetsService: AssetsService
    private let balanceUpdater: any BalanceUpdater
    private let priceUpdater: any PriceUpdater

    public init(
        assetsService: AssetsService,
        balanceUpdater: any BalanceUpdater,
        priceUpdater: any PriceUpdater
    ) {
        self.assetsService = assetsService
        self.balanceUpdater = balanceUpdater
        self.priceUpdater = priceUpdater
    }

    public func enableAssets(wallet: Wallet, assetIds: [AssetId], enabled: Bool) async throws {
        let walletId = wallet.walletId
        for assetId in assetIds {
            try assetsService.addBalanceIfMissing(walletId: walletId, assetId: assetId)
        }

        try assetsService.updateEnabled(walletId: walletId, assetIds: assetIds, enabled: enabled)

        guard enabled else { return }

        async let balanceUpdate: () = balanceUpdater.updateBalance(for: wallet, assetIds: assetIds)
        async let priceUpdate: () = priceUpdater.addPrices(assetIds: assetIds)
        _ = await balanceUpdate
        _ = try await priceUpdate
    }

    public func enableAssetId(wallet: Wallet, assetId: AssetId) async throws {
        let asset = try await assetsService.getOrFetchAsset(for: assetId)
        try await enableAssets(wallet: wallet, assetIds: [asset.id], enabled: true)
    }
}
