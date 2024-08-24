// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetId {
    static func mock(
        _ assetId: AssetId = AssetId(chain: .bitcoin, tokenId: .none)
    ) -> AssetId {
        assetId
    }
}
