// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Asset {
    init(_ chain: Chain) {
        let asset = chain.asset
        self.init(
            id: chain.assetId,
            name: asset.name,
            symbol: asset.symbol,
            decimals: asset.decimals,
            type: asset.type
        )
    }

    var feeAsset: Asset {
        switch id.chain {
        case .hyperCore:
            return Asset.hyperliquidUSDC()
        default:
            switch id.type {
            case .native: return self
            case .token: return id.chain.asset
            }
        }
    }
}
