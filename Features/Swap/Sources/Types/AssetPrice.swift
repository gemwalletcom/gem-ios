// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AssetPriceValue {
    public let asset: Asset
    public let price: Price?
    
    public init(asset: Asset, price: Price?) {
        self.asset = asset
        self.price = price
    }
}
