// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

public extension AssetProperties {
    static func defaultValue(assetId: AssetId) -> AssetProperties {
        let config = Gemstone.Config().getChainConfig(chain: assetId.chain.rawValue)
        return AssetProperties(
            isBuyable: false,
            isSellable: false,
            isSwapable: config.isSwapSupported,
            isStakeable: false,
            stakingApr: .none
        )
    }
}
