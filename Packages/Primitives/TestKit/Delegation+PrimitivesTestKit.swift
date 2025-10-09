// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Delegation {
    static func mock(
        state: DelegationState = .active,
        validator: DelegationValidator = .mock(),
        price: Price? = nil,
        base: DelegationBase? = nil
    ) -> Delegation {
        Delegation(
            base: base ?? .mock(state: state),
            validator: validator,
            price: price
        )
    }
}
