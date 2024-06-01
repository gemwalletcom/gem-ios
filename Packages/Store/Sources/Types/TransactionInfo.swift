// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct TransactionInfo: Codable, FetchableRecord {
    public let transaction: TransactionRecord
    public let asset: AssetRecord
    public let feeAsset: AssetRecord
    public let price: Price?
    public let feePrice: Price?
    public let assets: [AssetRecord]
}

extension TransactionInfo {
    func mapToTransactionExtended() -> TransactionExtended {
        TransactionExtended(
            transaction: transaction.mapToTransaction(),
            asset: asset.mapToAsset(),
            feeAsset: feeAsset.mapToAsset(),
            price: price,
            feePrice: feePrice,
            assets: assets.map { $0.mapToAsset() }
        )
    }
}
