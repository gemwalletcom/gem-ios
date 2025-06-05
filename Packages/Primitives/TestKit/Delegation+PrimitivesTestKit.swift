// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Delegation {
    static func mock(
        state: DelegationState
    ) -> Delegation {
        Delegation(
            base: .mock(state: state),
            validator: .mock(),
            price: nil
        )
    }
}
