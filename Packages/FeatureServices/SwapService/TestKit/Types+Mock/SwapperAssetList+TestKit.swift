// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapperAssetList

public extension SwapperAssetList {
    static func mock() -> SwapperAssetList {
        SwapperAssetList(
            chains: ["ethereum"],
            assetIds: ["ethereum:0xdac17f958d2ee523a2206206994597c13d831ec7"]
        )
    }
}
