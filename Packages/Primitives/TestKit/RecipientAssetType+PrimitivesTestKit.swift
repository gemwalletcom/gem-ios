// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension RecipientAssetType {
    static func mockAsset(_ asset: Asset = .mock()) -> RecipientAssetType {
        .asset(asset)
    }
    
    static func mockNft(_ asset: NFTAsset = .mock()) -> RecipientAssetType {
        .nft(asset)
    }
}