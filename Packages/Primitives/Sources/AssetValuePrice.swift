// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct AssetValuePrice: Sendable {
    public let asset: Asset
    public let value: BigInt
    public let price: Price?

    public init(asset: Asset, value: BigInt, price: Price?) {
        self.asset = asset
        self.value = value
        self.price = price
    }
}
