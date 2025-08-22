// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemDelegation {
    public func map() throws -> Delegation {
        return Delegation(
            base: try base.map(),
            validator: try validator.map(),
            price: nil
        )
    }
}

extension Delegation {
    public func map() -> GemDelegation {
        return GemDelegation(
            base: base.map(),
            validator: validator.map()
        )
    }
}