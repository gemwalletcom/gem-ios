// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemYield {
    public func map() throws -> EarnProtocol {
        EarnProtocol(
            name: name,
            assetId: try AssetId(id: assetId),
            provider: provider.map(),
            apy: apy
        )
    }
}
