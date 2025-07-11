// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension NFTAssetData {
    static func mock(
        collection: NFTCollection = .mock(),
        asset: NFTAsset = .mock()
    ) -> NFTAssetData {
        NFTAssetData(
            collection: collection,
            asset: asset
        )
    }
}