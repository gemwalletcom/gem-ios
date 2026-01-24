// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetProperties {
    static func defaultValue(assetId: AssetId) -> AssetProperties {
        let isStakeable = switch assetId.type {
        case .native: assetId.chain.isStakeSupported
        case .token: false
        }
        let isSwapable = assetId.chain.isSwapSupported
        return AssetProperties(
            isEnabled: true,
            isBuyable: false,
            isSellable: false,
            isSwapable: isSwapable,
            isStakeable: isStakeable,
            stakingApr: .none,
            isEarnable: false,
            earnApr: .none
        )
    }
}

public extension AssetScore {
    static func defaultValue(assetId: AssetId) -> AssetScore {
        switch assetId.type {
        case .native: AssetScore.defaultScore(chain: assetId.chain)
        case .token: AssetScore(rank: 15)
        }
    }
}
