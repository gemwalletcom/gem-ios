// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension AssetBasic {
    static func mock(
        asset: Asset = .mock(),
        properties: AssetProperties = .mock(),
        score: AssetScore = .mock()
    ) -> Self {
        AssetBasic(
            asset: asset,
            properties: properties,
            score: score
        )
    }
}
