// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetProperties {
    static func defaultValue(assetId: AssetId) -> AssetProperties {
        return AssetProperties(
            isBuyable: false,
            isSellable: false,
            isSwapable: assetId.chain.isSwapSupported,
            isStakeable: assetId.chain.isStakeSupported,
            stakingApr: .none
        )
    }
}
