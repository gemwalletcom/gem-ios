// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension DelegationValidator {
    static func mock() -> DelegationValidator {
        DelegationValidator(
            chain: .tron,
            id: .empty,
            name: .empty,
            isActive: true,
            commision: 1.0,
            apr: 13.0
        )
    }
}
