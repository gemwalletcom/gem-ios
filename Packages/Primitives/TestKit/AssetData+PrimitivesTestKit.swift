// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetData {
    static func mock(
        asset: Asset = .mock(),
        balance: Balance = .zero,
        account: Account = .mock(),
        price: Price? = nil,
        priceAlerts: [PriceAlert] = [],
        metadata: AssetMetaData = AssetMetaData(
            isEnabled: true,
            isBalanceEnabled: true,
            isBuyEnabled: true,
            isSellEnabled: true,
            isSwapEnabled: true,
            isStakeEnabled: true,
            stakingApr: .none,
            isEarnEnabled: false,
            earnApr: .none,
            isPinned: true,
            isActive: true,
            rankScore: 42
        ),
        isEarnable: Bool = false
    ) -> AssetData {
        AssetData(
            asset: asset,
            balance: balance,
            account: account,
            price: price,
            priceAlerts: priceAlerts,
            metadata: metadata,
            isEarnable: isEarnable
        )
    }
}
