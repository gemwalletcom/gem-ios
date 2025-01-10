// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

typealias TransferDataAction = ((TransferData) -> Void)?
typealias RecipientDataAction = ((RecipientData) -> Void)?

struct TransferDataMetadata {
    let assetBalance: BigInt
    let assetFeeBalance: BigInt
    
    let assetPrice: Price?
    let feePrice: Price?
    
    let assetPrices: [String: Price]
}

extension TransferDataMetadata: Hashable {}
