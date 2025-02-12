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
    
    var accountActivationFee: Int32? {
        ChainConfig.config(chain: self).accountActivationFee
    }
    
    var accountActivationFeeUrl: URL? {
        guard let url = ChainConfig.config(chain: self).accountActivationFeeUrl else {
            return .none
        }
        return URL(string: url)
    }
    
    var isMemoSupported: Bool {
        ChainConfig.config(chain: self).isMemoSupported
    }
    
    var isSwapSupported: Bool {
        ChainConfig.config(chain: self).isSwapSupported
    }
    
    var isStakeSupported: Bool {
        ChainConfig.config(chain: self).isStakeSupported
    }
    
    var isNFTSupported: Bool {
        ChainConfig.config(chain: self).isNftSupported
    }
    
    var type: ChainType {
        ChainType(rawValue: ChainConfig.config(chain: self).chainType)!
    }
    
    var feeUnitType: FeeUnitType {
        guard let feeUnitType = FeeUnitType(rawValue: ChainConfig.config(chain: self).feeUnitType) else {
            return .native
        }
        return feeUnitType
    }
}

extension Array where Element == Primitives.Chain {
    public func sortByRank() -> [Primitives.Chain] {
        self.sorted { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) }
    }
}
