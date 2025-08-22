// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemAsset {
    public func map() throws -> Asset {
        Asset(
            id: try AssetId(id: id),
            name: name,
            symbol: symbol,
            decimals: decimals,
            type: try AssetType(id: assetType)
        )
    }
}