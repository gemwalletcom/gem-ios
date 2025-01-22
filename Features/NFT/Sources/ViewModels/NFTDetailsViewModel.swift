// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components
import Style

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
    
    public var title: String {
        asset.name
    }
    
    public var description: String? {
        asset.description
    }
    
    public var collectionTitle: String {
        Localized.Nft.collection
    }
    
    public var collectionText: String {
        collection.name
    }
    
    public var collectionAssetImage: AssetImage {
        AssetImage(imageURL: URL(string: collection.image.previewImageUrl), placeholder: .none, chainPlaceholder: .none)
    }
    
    public var contractTitle: String {
        Localized.Asset.contract
    }

    public var contractText: String {
        AddressFormatter(address: contractValue, chain: asset.chain).value()
    }
    
    public var contractValue: String {
        collection.contractAddress
    }
    
    public var tokenIdTitle: String {
        Localized.Asset.tokenId
    }
    
    public var tokenIdText: String {
        "#\(asset.tokenId)"
    }
    
    public var attributesTitle: String {
        Localized.Nft.properties
    }
    
    public var attributes: [NFTAttribute] {
        asset.attributes
    }
    
    public var assetImage: AssetImage {
        AssetImage(
            imageURL: URL(string: asset.image.imageUrl),
            placeholder: Images.Chains.algorand,
            chainPlaceholder: .none
        )
    }
}
