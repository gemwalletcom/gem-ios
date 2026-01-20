// Copyright (c). Gem Wallet. All rights reserved.

import BalanceService
import Foundation
import PriceService
import Primitives

public protocol TransferMetadataProvidable: Sendable {
    func metadata(
        walletId: WalletId,
        asset: Asset,
        extraIds: [AssetId]
    ) throws -> TransferDataMetadata
}

public extension TransferMetadataProvidable {
    func metadata(
        wallet: Wallet,
        data: TransferData
    ) throws -> TransferDataMetadata {
        try metadata(
            walletId: wallet.walletId,
            asset: data.type.asset,
            extraIds: data.type.assetIds
        )
    }
}

public final class TransferMetadataProvider: TransferMetadataProvidable {
    private let balanceService: BalanceService
    private let priceService: PriceService

    public init(
        balanceService: BalanceService,
        priceService: PriceService
    ) {
        self.balanceService = balanceService
        self.priceService = priceService
    }

    public func metadata(
        walletId: WalletId,
        asset: Asset,
        extraIds: [AssetId] = []
    ) throws -> TransferDataMetadata {
        let assetId = asset.id
        let feeAssetId = asset.feeAsset.id

        guard let balance = try balanceService.getBalance(walletId: walletId, assetId: assetId) else {
            throw AnyError("Missing balance for assetId: \(assetId.identifier)")
        }
        guard let fee = try balanceService.getBalance(walletId: walletId, assetId: feeAssetId) else {
            throw AnyError("Missing balance for feeAssetId: \(feeAssetId.identifier)")
        }

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
