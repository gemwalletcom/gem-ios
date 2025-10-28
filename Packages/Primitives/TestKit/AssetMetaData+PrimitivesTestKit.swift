// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetMetaData {
    static func mock(
        isEnabled: Bool = true,
        isBalanceEnabled: Bool = true,
        isBuyEnabled: Bool = true,
        isSellEnabled: Bool = true,
        isSwapEnabled: Bool = true,
        isStakeEnabled: Bool = true,
        isPinned: Bool = true,
        isActive: Bool = true,
        stakingApr: Double? = nil,
        rankScore: Int32 = 42
    ) -> AssetMetaData {
        AssetMetaData(
            isEnabled: isEnabled,
            isBalanceEnabled: isBalanceEnabled,
            isBuyEnabled: isBuyEnabled,
            isSellEnabled: isSellEnabled,
            isSwapEnabled: isSwapEnabled,
            isStakeEnabled: isStakeEnabled,
            isPinned: isPinned,
            isActive: isActive,
            stakingApr: stakingApr,
            rankScore: rankScore
        )
    }
}
