// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public func mapHypercoreCoinToAssetId(_ coin: String, type: String = "perpetual") -> AssetId {
    AssetId(chain: .hyperCore, tokenId: AssetId.subTokenId([type, coin]))
}

public func mapHypercoreSpotCoinToAssetId(_ coin: String, token: UInt32) -> AssetId {
    // HYPE has token ID 150 and is the native token
    if token == 150 {
        return AssetId(chain: .hyperCore, tokenId: .none)
    }
    return AssetId(chain: .hyperCore, tokenId: coin)
}
