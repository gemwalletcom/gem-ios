// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemEarnProviderType {
    public func map() -> EarnProviderType {
        switch self {
        case .stake: .stake
        case .yield: .yield
        }
    }
}

extension EarnProviderType {
    public func map() -> GemEarnProviderType {
        switch self {
        case .stake: .stake
        case .yield: .yield
        }
    }
}

extension GemDelegationValidator {
    public func map() throws -> DelegationValidator {
        DelegationValidator(
            chain: try chain.map(),
            id: id,
            name: name,
            isActive: isActive,
            commission: commission,
            apr: apr,
            providerType: providerType.map()
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
            apr: apr,
            providerType: providerType.map()
        )
    }
}
