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
    
    public func asset(for assetId: AssetId) -> Asset? {
        assets.first(where: { $0.id == assetId })
    }
    
    public func price(for assetId: AssetId) -> Price? {
        assetPrices.first(where: { $0.assetId == assetId.identifier })?.mapToPrice()
    }
}
