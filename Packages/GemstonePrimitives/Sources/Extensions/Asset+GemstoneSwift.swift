// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension Asset {

    public init(_ chain: Chain) {
        let asset = chain.asset
        self.init(
            id: chain.assetId,
            name: asset.name,
            symbol: asset.symbol,
            decimals: asset.decimals,
            type: asset.type
        )
    }
    
    public var feeAsset: Asset {
        switch id.type {
        case .native: self
        case .token: id.chain.asset
        }
    }
}
