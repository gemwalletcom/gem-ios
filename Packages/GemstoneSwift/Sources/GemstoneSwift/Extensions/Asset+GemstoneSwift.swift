// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension Asset {

    public init(_ chain: Chain) {
        let asset = chain.asset
        self.init(
            id: AssetId(chain: chain, tokenId: .none),
            name: asset.name,
            symbol: asset.symbol,
            decimals: asset.decimals,
            type: asset.type
        )
    }
    
    public var feeAsset: Asset {
        switch id.type {
        case .native:
            return self
        case .token:
            return id.chain.asset
        }
    }
}
