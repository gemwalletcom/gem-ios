// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style
import ImageSaverService

public struct NFTDetailsViewModel: Sendable {
    public let collection: NFTCollection
    public let asset: NFTAsset
    private let headerButtonAction: HeaderButtonAction?
    
    public init(
        collection: NFTCollection,
        asset: NFTAsset,
        headerButtonAction: HeaderButtonAction?
    ) {
        self.collection = collection
        self.asset = asset
        self.headerButtonAction = headerButtonAction
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
        AssetImage(
            imageURL: URL(string: collection.image.previewImageUrl),
            placeholder: .none,
            chainPlaceholder: .none
        )
    }
    
    public var networkTitle: String {
        Localized.Transfer.network
    }
    
    public var networkText: String {
        asset.chain.asset.name
    }
    
    public var contractTitle: String {
        Localized.Asset.contract
    }
    
    public var networkAssetImage: AssetImage {
        AssetImage(
            imageURL: .none,
            placeholder: ChainImage(chain: asset.chain).image,
            chainPlaceholder: .none
        )
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
            type: asset.name,
            imageURL: URL(string: asset.image.imageUrl),
            placeholder: .none,
            chainPlaceholder: .none
        )
    }
    
    public var headerButtons: [HeaderButton] {
        [
            HeaderButton(type: .send, isEnabled: true),
            HeaderButton(type: .more, isEnabled: true),
        ]
    }
    
    func onHeaderAction(type: HeaderButtonType) {
        headerButtonAction?(type)
    }
    
    func saveImageToGallery() async throws {
        guard let url = URL(string: asset.image.imageUrl) else {
            throw AnyError("Wrong asset image url")
        }
        let saver = ImageSaverService()
        try await saver.saveImageFromURL(url)
    }
}
