// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetData {
    static func mock(
        asset: Asset = .mock(),
        balance: Balance = .zero,
        account: Account = .mock(),
        price: Price? = nil,
        priceAlert: PriceAlert? = nil,
        metadata: AssetMetaData = AssetMetaData(
            isEnabled: true,
            isBuyEnabled: true,
            isSellEnabled: true,
            isSwapEnabled: true,
            isStakeEnabled: true,
            isPinned: true,
            isActive: true,
            stakingApr: .none
        )
    ) -> AssetData {
        AssetData(
            asset: .mock(),
            balance: balance,
            account: account,
            price: price,
            price_alert: priceAlert,
            metadata: metadata
        )
    }
}
