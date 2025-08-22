// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemDelegationValidator {
    public func map() throws -> DelegationValidator {
        DelegationValidator(
            chain: try Chain(id: chain),
            id: id,
            name: name,
            isActive: isActive,
            commision: commission,
            apr: apr
        )
    }
}