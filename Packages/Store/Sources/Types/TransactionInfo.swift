// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct TransactionInfo: Codable, FetchableRecord {
    let transaction: TransactionRecord
    let asset: AssetRecord
    let feeAsset: AssetRecord
    let price: PriceRecord?
    let feePrice: PriceRecord?
    let assets: [AssetRecord]
    let prices: [PriceRecord]
    let fromAddress: AddressRecord?
    let toAddress: AddressRecord?
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
