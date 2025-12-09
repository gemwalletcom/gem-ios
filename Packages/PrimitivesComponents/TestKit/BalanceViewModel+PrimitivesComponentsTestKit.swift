// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

public extension BalanceViewModel {
    static func mock(
        asset: Asset = .mock(),
        balance: Balance = .mock(),
        formatter: ValueFormatter = .auto
    ) -> BalanceViewModel {
        BalanceViewModel(
            asset: asset,
            balance: balance,
            formatter: formatter
        )
    }
}
