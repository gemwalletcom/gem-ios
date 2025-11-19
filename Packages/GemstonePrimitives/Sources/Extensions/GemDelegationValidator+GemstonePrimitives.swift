// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemDelegationValidator {
    public func map() throws -> DelegationValidator {
        DelegationValidator(
            chain: try chain.map(),
            id: id,
            name: name,
            isActive: isActive,
            commission: commission,
            apr: apr
        )
    }
}

extension DelegationValidator {
    public func map() -> GemDelegationValidator {
        return GemDelegationValidator(
            chain: chain.rawValue,
            id: id,
            name: name,
            isActive: isActive,
            commission: commission,
            apr: apr
        )
    }
}
