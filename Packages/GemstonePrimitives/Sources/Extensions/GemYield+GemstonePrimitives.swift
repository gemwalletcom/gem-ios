// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemYield {
    public func mapToEarnProvider() throws -> EarnProvider {
        let assetId = try AssetId(id: assetId)
        return EarnProvider(
            chain: assetId.chain,
            id: provider.map().rawValue,
            name: name,
            isActive: true,
            fee: 0,
            apy: apy ?? 0,
            providerType: .yield
        )
    }
}
