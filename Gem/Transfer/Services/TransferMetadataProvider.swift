// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService
import PriceService

public protocol TransferMetadataProviding: Sendable {
    func snapshot(
        walletId: WalletId,
        asset: Asset,
        extraIds: [AssetId]
    ) throws -> TransferDataMetadata
}

public extension TransferMetadataProviding {
    func snapshot(
        wallet: Wallet,
        data: TransferData
    ) throws -> TransferDataMetadata {
        try snapshot(
            walletId: wallet.walletId,
            asset: data.type.asset,
            extraIds: data.type.assetIds
        )
    }
}

public enum TransferMetadataProviderError: Error {
    case missingBalance
}

public final class TransferMetadataProvider: TransferMetadataProviding {
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
    ) throws -> TransferDataMetadata {

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
        else { throw TransferMetadataProviderError.missingBalance }

        let ids = Array(Set([assetId, feeAssetId] + extraIds))
        let pricesList = try priceService.getPrices(for: ids)
        let prices = Dictionary(uniqueKeysWithValues: pricesList.map { ($0.assetId, $0.mapToPrice()) })

        return TransferDataMetadata(
            assetId: assetId,
            feeAssetId: feeAssetId,
            assetBalance: balance,
            assetFeeBalance: fee,
            assetPrices: prices
        )
    }
}
