// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
@testable import Primitives

public extension AssetValuePrice {
    static func mock(
        asset: Asset = Asset.mock(),
        value: BigInt = BigInt(100_000_000),
        price: Price? = Price.mock(price: 1.0)
    ) -> AssetValuePrice {
        AssetValuePrice(asset: asset, value: value, price: price)
    }
}