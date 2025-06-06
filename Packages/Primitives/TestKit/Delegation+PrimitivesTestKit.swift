// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Delegation {
    static func mock(
        state: DelegationState,
        validator: DelegationValidator = .mock()
    ) -> Delegation {
        Delegation(
            base: .mock(state: state),
            validator: validator,
            price: nil
        )
    }
}
