// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension AssetProperties {
    static func mock(stakingApr: Double? = 13.5) -> Self {
        AssetProperties(
            isEnabled: true,
            isBuyable: true,
            isSellable: true,
            isSwapable: true,
            isStakeable: true,
            stakingApr: stakingApr
        )
    }
}
