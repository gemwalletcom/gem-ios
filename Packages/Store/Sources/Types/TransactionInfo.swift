// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct TransactionInfo: Codable, FetchableRecord {
    public let transaction: TransactionRecord
    public let asset: AssetRecord
    public let feeAsset: AssetRecord
    public let price: PriceRecord?
    public let feePrice: PriceRecord?
    public let assets: [AssetRecord]
    public let prices: [PriceRecord]
    public let fromAddress: AddressRecord?
    public let toAddress: AddressRecord?
}

extension TransactionInfo {
    func mapToTransactionExtended() -> TransactionExtended {
        TransactionExtended(
            transaction: transaction.mapToTransaction(),
            asset: asset.mapToAsset(),
            feeAsset: feeAsset.mapToAsset(),
            price: price?.mapToPrice(),
            feePrice: feePrice?.mapToPrice(),
            assets: assets.map { $0.mapToAsset() },
            prices: prices.map { $0.mapToAssetPrice() },
            fromAddress: fromAddress?.asPrimitive(),
            toAddress: toAddress?.asPrimitive()
        )
    }
}
