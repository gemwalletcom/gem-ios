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
        stakingApr: Double? = nil,
        isEarnEnabled: Bool = false,
        earnApr: Double? = nil,
        isPinned: Bool = true,
        isActive: Bool = true,
        rankScore: Int32 = 42
    ) -> AssetMetaData {
        AssetMetaData(
            isEnabled: isEnabled,
            isBalanceEnabled: isBalanceEnabled,
            isBuyEnabled: isBuyEnabled,
            isSellEnabled: isSellEnabled,
            isSwapEnabled: isSwapEnabled,
            isStakeEnabled: isStakeEnabled,
            stakingApr: stakingApr,
            isEarnEnabled: isEarnEnabled,
            earnApr: earnApr,
            isPinned: isPinned,
            isActive: isActive,
            rankScore: rankScore
        )
    }
}
