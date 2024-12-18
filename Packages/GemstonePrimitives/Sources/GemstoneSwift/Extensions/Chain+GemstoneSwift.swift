// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import BigInt

public extension Primitives.Chain {
    var asset: Asset {
        let assetWrapper = Gemstone.assetWrapper(chain: id)
        return Asset(
            id: assetId,
            name: assetWrapper.name,
            symbol: assetWrapper.symbol,
            decimals: assetWrapper.decimals,
            type: .native
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
    
    var accountActivationFeeUrl: URL? {
        guard let url = ChainConfig.config(chain: self).accountActivationFeeUrl else {
            return .none
        }
        return URL(string: url)
    }
}
