// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct AssetPortfolio: Sendable, Hashable {
    public let assetId: AssetId
    public let feeAssetId: AssetId
    public let balance: Balance
    public let feeBalance: Balance

    public let prices: [AssetId: Price]

    public init(
        assetId: AssetId,
        feeAssetId: AssetId,
        balance: Balance,
        feeBalance: Balance,
        prices: [AssetId: Price]
    ) {
        self.assetId = assetId
        self.feeAssetId = feeAssetId
        self.balance = balance
        self.feeBalance = feeBalance
        self.prices = prices
    }
}

public extension AssetPortfolio {
    var available: BigInt { balance.available }
    var feeAvailable: BigInt { feeBalance.available }

    var assetPrice: Price? { prices[assetId] }
    var feePrice: Price? { prices[feeAssetId] }

    func asMetadata() -> TransferDataMetadata {
        .init(
            assetBalance: available,
            assetFeeBalance: feeAvailable,
            assetPrice: assetPrice,
            feePrice: feePrice,
            assetPrices: prices
        )
    }
}
