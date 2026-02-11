// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemYield {
    public func map() throws -> DelegationValidator {
        DelegationValidator(
            chain: try AssetId(id: assetId).chain,
            id: provider.map().rawValue,
            name: name,
            isActive: true,
            commission: 0,
            apr: apy ?? 0,
            providerType: .earn
        )
    }
}
