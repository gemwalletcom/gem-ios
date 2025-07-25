// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public func mapHypercoreCoinToAssetId(_ coin: String, type: String = "perpetual") -> AssetId {
    AssetId(chain: .hyperCore, tokenId: AssetId.subTokenId([type, coin]))
}
