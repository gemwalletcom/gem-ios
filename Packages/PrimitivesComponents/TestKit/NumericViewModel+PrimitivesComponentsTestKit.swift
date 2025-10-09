// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

public extension NumericViewModel {
    static func mock(
        asset: Asset = Asset.mock(),
        price: Price? = Price.mock(price: 1.0),
        value: BigInt = BigInt(100_000_000),
        sign: AmountDisplaySign = .none,
        formatter: ValueFormatter = .full,
        currencyCode: String = "USD"
    ) -> NumericViewModel {
        let data = AssetValuePrice(asset: asset, value: value, price: price)
        let style = AmountDisplayStyle(
            sign: sign,
            formatter: formatter,
            currencyCode: currencyCode
        )
        return NumericViewModel(data: data, style: style)
    }
}