// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapAssetList

public extension SwapAssetList {
    static func mock() -> SwapAssetList {
        SwapAssetList(
            chains: ["ethereum"],
            assetIds: ["ethereum:0xdac17f958d2ee523a2206206994597c13d831ec7"]
        )
    }
}
