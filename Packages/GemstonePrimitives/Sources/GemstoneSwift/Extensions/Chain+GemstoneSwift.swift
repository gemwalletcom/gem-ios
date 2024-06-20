// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public extension Chain {
    var asset: Asset {
        //TODO: Force unwrap for now, until move Asset to Gemstone
        let assetWrapper = Gemstone.assetWrapper(chain: id)
        return Asset(
            id: AssetId(id: assetWrapper.id)!,
            name: assetWrapper.name,
            symbol: assetWrapper.symbol,
            decimals: assetWrapper.decimals,
            type: AssetType(rawValue: assetWrapper.assetType)!
        )
    }

    var includeStakedBalance: Bool {
        switch self.stakeChain {
        case .cosmos,
                .osmosis,
                .injective,
                .sei,
                .celestia,
                .solana,
                .sui,
                .smartChain,
                .none:
            true
        case .ethereum:
            // stETH duplicate portfolio
            false
        }
    }
}
