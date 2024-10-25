// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import BigInt
public extension Chain {
    var asset: Asset {
        //TODO: Force unwrap for now, until move Asset to Gemstone
        let assetWrapper = Gemstone.assetWrapper(chain: id)
        return Asset(
            id: try! AssetId(id: assetWrapper.id),
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
                .tron,
                .none:
            true
        case .ethereum:
            // stETH duplicate portfolio
            false
        }
    }

    var accountActivationFee: Int32? {
        ChainConfig.config(chain: self).accountActivationFee
    }
}
