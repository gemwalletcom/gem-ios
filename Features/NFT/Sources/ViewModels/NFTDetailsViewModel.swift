// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct NFTDetailsViewModel {
    public let collection: NFTCollection
    public let asset: NFTAsset
    
    public init(
        collection: NFTCollection,
        asset: NFTAsset
    ) {
        self.collection = collection
        self.asset = asset
    }
    
    public var name: String {
        asset.name
    }
    
    public var description: String? {
        asset.description
    }
    
    public var attributes: [NFTAttribute] {
        asset.attributes
    }
    
    public var imageURL: URL? {
        URL(string: asset.image.imageUrl)
    }
}
