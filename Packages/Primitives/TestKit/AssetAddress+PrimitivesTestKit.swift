// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension AssetAddress {
    static func mock(
        asset: Asset = .mock(),
        address: String = ""
    ) -> AssetAddress {
        AssetAddress(
            asset: asset,
            address: address
        )
    }
}
