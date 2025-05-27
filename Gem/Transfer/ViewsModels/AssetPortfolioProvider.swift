// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
import PriceService

private enum AssetPortfolioProviderError: Error {
    case missingBalance
}

public final class AssetPortfolioProvider: AssetPortfolioProviding {
    private let balanceService: BalanceService
    private let priceService: PriceService

    public init(
        balanceService: BalanceService,
        priceService: PriceService
    ) {
        self.balanceService = balanceService
        self.priceService = priceService
    }

    public func snapshot(
        walletId: WalletId,
        asset: Asset,
        extraIds: [AssetId] = []
    ) throws -> AssetPortfolio {

        let assetId = asset.id
        let feeAssetId = asset.feeAsset.id

        guard
            let balance = try balanceService.getBalance(
                walletId: walletId.id,
                assetId: assetId.identifier
            ),
            let fee = try balanceService.getBalance(
                walletId: walletId.id,
                assetId: feeAssetId.identifier
            )
        else { throw AssetPortfolioProviderError.missingBalance }

        let ids = [assetId, feeAssetId] + extraIds
        let pricesList = try priceService.getPrices(for: ids)
        let prices = Dictionary(uniqueKeysWithValues: pricesList.map { ($0.assetId, $0.mapToPrice()) })

        return AssetPortfolio(
            assetId: assetId,
            feeAssetId: feeAssetId,
            balance: balance,
            feeBalance: fee,
            prices: prices
        )
    }
}
