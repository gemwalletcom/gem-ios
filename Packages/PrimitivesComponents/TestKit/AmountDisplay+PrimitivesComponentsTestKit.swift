// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

public extension AmountDisplay {
    static func mock(
        asset: Asset = Asset.mock(),
        price: Price? = Price.mock(price: 1.0),
        value: BigInt = BigInt(100_000_000),
        direction: TransactionDirection? = nil,
        currency: String = "USD",
        formatter: ValueFormatter = .full
    ) -> AmountDisplay {
        .numeric(
            asset: asset,
            price: price,
            value: value,
            direction: direction,
            currency: currency,
            formatter: formatter
        )
    }

    static func mockSymbol(asset: Asset = Asset.mock()) -> AmountDisplay {
        .symbol(asset: asset)
    }
}