// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferDataMetadata: Sendable, Hashable {
    public let assetId: AssetId
    public let feeAssetId: AssetId

    public let assetBalance: Balance
    public let assetFeeBalance: Balance

    public let assetPrices: [AssetId: Price]

    public init(
        assetId: AssetId,
        feeAssetId: AssetId,
        assetBalance: Balance,
        assetFeeBalance: Balance,
        assetPrices: [AssetId: Price]
    ) {
        self.assetId = assetId
        self.feeAssetId = feeAssetId
        self.assetBalance = assetBalance
        self.assetFeeBalance = assetFeeBalance
        self.assetPrices = assetPrices
    }
}

public extension TransferDataMetadata {
    var available: BigInt { assetBalance.available }
    var feeAvailable: BigInt { assetFeeBalance.available }

    var assetPrice: Price? { assetPrices[assetId] }
    var feePrice: Price? { assetPrices[feeAssetId] }
}
