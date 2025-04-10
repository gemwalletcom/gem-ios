// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension AssetScore {
    static func mock(rank: Int32 = 1) -> Self {
        AssetScore(rank: rank)
    }
}
