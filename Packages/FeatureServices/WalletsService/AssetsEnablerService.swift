// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import AssetsService

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

    public func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async throws {
        for assetId in assetIds {
            try assetsService.addBalanceIfMissing(walletId: walletId, assetId: assetId)
        }

        try assetsService.updateEnabled(walletId: walletId, assetIds: assetIds, enabled: enabled)

        guard enabled else { return }

        async let balanceUpdate: () = balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
        async let priceUpdate: () = priceUpdater.addPrices(assetIds: assetIds)
        _ = try await (balanceUpdate, priceUpdate)
    }

    public func enableAssetId(walletId: WalletId, assetId: AssetId) async throws {
        let asset = try await assetsService.getOrFetchAsset(for: assetId)
        try await enableAssets(walletId: walletId, assetIds: [asset.id], enabled: true)
    }
}
