// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public extension TransferDataMetadata {
    var available: BigInt { assetBalance.available }
    var feeAvailable: BigInt { assetFeeBalance.available }

    var assetPrice: Price? { assetPrices[assetId] }
    var feePrice: Price? { assetPrices[feeAssetId] }
}
