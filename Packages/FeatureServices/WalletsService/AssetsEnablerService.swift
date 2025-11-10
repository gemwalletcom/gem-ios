// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import AssetsService

struct AssetsEnablerService: AssetsEnabler {
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

    func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async {
        do {
            for assetId in assetIds {
                try assetsService.addBalanceIfMissing(walletId: walletId, assetId: assetId)
            }
            try assetsService.updateEnabled(walletId: walletId, assetIds: assetIds, enabled: enabled)
            // If enabling, also update balances and prices
            if enabled {
                async let balanceUpdate: () = balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
                async let priceUpdate: () = priceUpdater.addPrices(assetIds: assetIds)
                _ = try await (balanceUpdate, priceUpdate)
            }
        } catch {
            debugLog("enableAssets error: \(error)")
        }
    }
}
