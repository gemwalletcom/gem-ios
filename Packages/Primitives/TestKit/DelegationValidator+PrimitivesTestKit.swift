// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension DelegationValidator {
    static func mock(
        _ chain: Chain = Chain.bitcoin,
        id: String = "1",
        name: String = "Test Delegation Validator",
        isActive: Bool = true,
        commision: Double = 5,
        apr: Double = 1
    ) -> DelegationValidator {
        DelegationValidator(
            chain: chain,
            id: id,
            name: name,
            isActive: isActive,
            commision: commision,
            apr: apr
        )
    }
}
