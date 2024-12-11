// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetProperties {
    static func defaultValue(assetId: AssetId) -> AssetProperties {
        let config = GemstoneConfig.shared.getChainConfig(chain: assetId.chain.rawValue)
        return AssetProperties(
            isBuyable: false,
            isSellable: false,
            isSwapable: config.isSwapSupported,
            isStakeable: config.isStakeSupported,
            stakingApr: .none
        )
    }
}
