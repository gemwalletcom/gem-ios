// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SwapMetadata: Sendable {
    public let assets: [Asset]
    public let assetPrices: [AssetPrice]
    public let transactionMetadata: TransactionSwapMetadata

    public init(
        assets: [Asset],
        assetPrices: [AssetPrice],
        transactionMetadata: TransactionSwapMetadata
    ) {
        self.assets = assets
        self.assetPrices = assetPrices
        self.transactionMetadata = transactionMetadata
    }
}
