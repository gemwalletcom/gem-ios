// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferDataMetadata: Sendable {
    public let assetBalance: BigInt
    public let assetFeeBalance: BigInt

    public let assetPrice: Price?
    public let feePrice: Price?

    public let assetPrices: [AssetId: Price]

    public init(
        assetBalance: BigInt,
        assetFeeBalance: BigInt,
        assetPrice: Price?,
        feePrice: Price?,
        assetPrices: [AssetId : Price]
    ) {
        self.assetBalance = assetBalance
        self.assetFeeBalance = assetFeeBalance
        self.assetPrice = assetPrice
        self.feePrice = feePrice
        self.assetPrices = assetPrices
    }
}

extension TransferDataMetadata: Hashable {}
