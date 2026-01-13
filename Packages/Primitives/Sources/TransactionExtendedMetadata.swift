// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionExtendedMetadata: Sendable {
    public let assets: [Asset]
    public let assetPrices: [AssetPrice]
    public let metadata: AnyCodableValue?

    public init(
        assets: [Asset],
        assetPrices: [AssetPrice],
        metadata: AnyCodableValue?
    ) {
        self.assets = assets
        self.assetPrices = assetPrices
        self.metadata = metadata
    }

    public func asset(for assetId: AssetId) -> Asset? {
        assets.first(where: { $0.id == assetId })
    }

    public func price(for assetId: AssetId) -> Price? {
        assetPrices.first(where: { $0.assetId == assetId })?.mapToPrice()
    }

    public var swapMetadata: TransactionSwapMetadata? {
        metadata?.decode(TransactionSwapMetadata.self)
    }

    public var nftMetadata: TransactionNFTTransferMetadata? {
        metadata?.decode(TransactionNFTTransferMetadata.self)
    }
}
