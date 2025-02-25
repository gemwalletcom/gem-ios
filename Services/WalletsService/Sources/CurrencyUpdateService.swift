// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import AssetsService

struct CurrencyUpdateService: CurrencyUpdater {
    private let assetsService: AssetsService
    private let balanceUpdater: any BalanceUpdater
    private let priceUpdater: any PriceUpdater

    init(assetsService: AssetsService, balanceUpdater: any BalanceUpdater, priceUpdater: any PriceUpdater) {
        self.assetsService = assetsService
        self.balanceUpdater = balanceUpdater
        self.priceUpdater = priceUpdater
    }

    func changeCurrency(for walletId: WalletId) async throws {
        // TODO: - here need a cancel logic if updatePrices & updateBalance in progress, but someone changes in one more time
        // updates prices
        try priceUpdater.clear()
        let assetIds = try assetsService.getAssets().assetIds
        try await priceUpdater.updatePrices(assetIds: assetIds)
        // update balances
        let enabledAssetIds = try assetsService.getEnabledAssets()
        try await balanceUpdater.updateBalance(for: walletId, assetIds: enabledAssetIds)
    }
}
