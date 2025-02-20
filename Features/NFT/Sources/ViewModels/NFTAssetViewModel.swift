// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components

public struct NFTAssetViewModel {
    public let asset: NFTAsset
    
    public init(asset: NFTAsset) {
        self.asset = asset
    }
    
    public var assetImage: AssetImage {
        AssetImage(
            type: asset.name,
            imageURL: asset.image.imageUrl.asURL,
            placeholder: .none,
            chainPlaceholder: .none
        )
    }
}
