// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemAssetBalance {
    public func map() throws -> AssetBalance {
        AssetBalance(
            assetId: try AssetId(id: assetId),
            balance: try balance.map(),
            isActive: isActive
        )
    }
}