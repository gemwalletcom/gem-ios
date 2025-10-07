// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPrice {
    public func map() -> Price {
        Price(
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: Date(timeIntervalSince1970: TimeInterval(updatedAt))
        )
    }
}

extension Price {
    public func map() -> GemPrice {
        GemPrice(
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: Int64(updatedAt.timeIntervalSince1970)
        )
    }
}

extension GemDelegation {
    public func map() throws -> Delegation {
        Delegation(
            base: try base.map(),
            validator: try validator.map(),
            price: price?.map()
        )
    }
}

extension Delegation {
    public func map() -> GemDelegation {
        GemDelegation(
            base: base.map(),
            validator: validator.map(),
            price: price?.map()
        )
    }
}
